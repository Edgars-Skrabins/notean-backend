# Backend TODO

## "My team" lookup — needed for login flow

Frontend requirement: after logging in, a user who already belongs to a team should skip team selection and land straight in the dashboard with that team active. There's currently no way to look this up — no endpoint returns "what team(s) does the current user belong to."

Confirmed with the user: if someone belongs to more than one team (no team switcher UI exists yet), auto-select their **most recently joined/created** one.

**`GET /teams/mine`** — requires auth, no team-scoping (this is user-scoped, not team-scoped)
- Look up `current_user.memberships.order(created_at: :desc).first&.team`
- Success `200` either way (absence of a team is a normal state, not an error): `{ team: { id, name, code } | null }`

**Routing gotcha**: declare this route **before** `resources :teams, param: :code`, not after. Since teams use `:code` as the member-route param, `GET /teams/mine` would otherwise get swallowed by `GET /teams/:code` (Rails matches routes in declaration order, and `mine` is a valid match for the `:code` wildcard).
```ruby
get "teams/mine" => "teams#mine"
resources :teams, only: [:create, :show], param: :code do
  resources :pages, only: [:index, :create, :show, :update, :destroy]
end
```

## Pages feature — done, verified matching the frontend

Read through all three commits (`add pages data model`, `add pages CRUD API`, `add live 'currently editing' indicator via Action Cable`) against what the frontend actually calls — routes, JSON shapes (`creator`/`contributors`/`currently_editing`), the Action Cable payload shape, and the `?token=` query-param auth on the cable connection all line up correctly. No changes needed here.

## Pages feature — original specification (for reference)

A Confluence-style document list per team: create a page with a title, write/format its content, search by title, edit with a "someone's editing this" indicator, and track who created and who has contributed to each page.

Decisions confirmed with the user:
- **Content format**: rich HTML (sanitized before storage), not Markdown or a structured JSON doc.
- **Edit "lock"**: soft indicator only — nothing stops a second user from also entering edit mode. It's purely informational ("X is editing this"), no conflict prevention. Last save wins.
- **Editing status updates live** via WebSockets (Action Cable — already scaffolded in `app/channels/`), not just on page load/reload.
- **Sidebar "Owner"** = the page's creator (a user), not the team. The team relationship is implicit (every page belongs to a team) and isn't shown as a separate "Owner" field.
- **Contributors** = a distinct set of users who have successfully saved an edit — each shown once, no per-edit history (not a full revision log).
- **Search** is a backend endpoint (`?search=`), case-insensitive partial match on title — not client-side filtering.
- **Creation flow**: clicking "+" creates the page immediately (empty content, e.g. default title "Untitled"), then opens it in edit mode. Save just updates that existing record.
- **Permissions**: any team member can create, edit, or delete any page in their team. No role-gating (owner/member roles on `Membership` aren't used for page permissions).

### Assumptions I'm making that weren't specified — flag if wrong

- **No title uniqueness constraint** — two pages in the same team can share a title.
- **No version history** — saving overwrites `content` in place. Only the current content + the distinct contributor set + `created_at`/`updated_at` are kept, nothing per-revision.
- **The creator is NOT automatically a contributor at creation time.** Since "+" creates an empty/untitled page with no real content written yet, the creator only joins the contributors list the first time they (or anyone) actually saves an edit — matching "when someone successfully edits and saves the page, they will be attached as contributing users" literally. If you actually want the creator counted as a contributor immediately on creation, that's a one-line change (add them to `page_contributors` in the `create` action too).

### Data model

`pages` table:
```
id
team_id          references teams, null: false
created_by_user_id  references users, null: false   # the "Owner" shown in the UI
title            string, null: false
content          text, null: false, default: ''      # sanitized HTML
created_at, updated_at
```

`page_contributors` table (join table — the distinct contributor set):
```
id
page_id  references pages, null: false
user_id  references users, null: false
created_at, updated_at
unique index on [page_id, user_id]
```

Models:
```ruby
class Page < ApplicationRecord
  belongs_to :team
  belongs_to :creator, class_name: 'User', foreign_key: :created_by_user_id
  has_many :page_contributors
  has_many :contributors, through: :page_contributors, source: :user

  validates :title, presence: true
end

class PageContributor < ApplicationRecord
  belongs_to :page
  belongs_to :user
  validates :user_id, uniqueness: { scope: :page_id }
end
```

### Routes

Nested under teams, using the existing `:code` param convention:
```ruby
resources :teams, only: [:create, :show], param: :code do
  resources :pages, only: [:index, :create, :show, :update, :destroy]
end
```
Gives: `GET/POST /teams/:team_code/pages`, `GET/PATCH/DELETE /teams/:team_code/pages/:id`.

All routes require auth (`authenticate_user!`) **and** team membership — add a `before_action` that finds the team by `params[:team_code]` and checks `current_user.memberships.exists?(team: @team)`, rendering `403` if not a member. (Worth pulling into a shared concern once Diagrams/Kanban boards need the same check.)

### Endpoints

**`GET /teams/:team_code/pages`** — list, optionally `?search=<query>`
- Case-insensitive partial match on `title` when `search` is present (`Page.where(team: @team).where('LOWER(title) LIKE ?', "%#{query.downcase}%")` — works portably, not SQLite-specific)
- Returns **summaries only** (no `content` — keep the list response light): `{ id, title, creator: { id, username }, created_at, updated_at }`
- Success `200`, empty array if none match

**`POST /teams/:team_code/pages`** — create
- Body: `{ page: { title } }` — `title` optional, defaults to `"Untitled"` if blank; `content` always starts `''`
- Sets `created_by_user_id` to `current_user.id`
- Success `201`: `{ page: { id, title, content, creator, contributors: [], created_at, updated_at } }`

**`GET /teams/:team_code/pages/:id`** — full page
- Success `200`: `{ page: { id, title, content, creator: {id, username}, contributors: [{id, username}, ...], created_at, updated_at, currently_editing: { id, username } | null } }`
- `currently_editing` read from the same ephemeral store the Action Cable channel uses (below) — so a freshly-loaded page immediately shows the current editor without waiting for a socket push
- `404` if not found in this team

**`PATCH /teams/:team_code/pages/:id`** — save
- Body: `{ page: { title, content } }`
- Sanitize `content` server-side before saving (strip script tags/event handlers/etc — use `rails-html-sanitizer`, already a Rails dependency, not a new gem) — this is user-authored rich text being persisted and later rendered back as HTML, so treat it as untrusted input
- `find_or_create` a `PageContributor` for `(page, current_user)`
- As a safety net, also clear this page's entry in the editing-status store if it belongs to `current_user` (in case the client's `stop_editing` socket message didn't arrive)
- Success `200`, same shape as create

**`DELETE /teams/:team_code/pages/:id`** — delete
- Any team member, per your answer. Success `204`.

### Real-time "being edited" indicator — Action Cable

No DB column for editing status — it's ephemeral, presence-style state, not durable data. Store it in `Rails.cache` (in-memory in dev; needs a shared backend like Redis in production once there's more than one server process) keyed by `page_id`.

```ruby
class PageEditingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "page_editing_#{params[:page_id]}"
  end

  def unsubscribed
    clear_if_current_editor
  end

  def start_editing
    Rails.cache.write(cache_key, { user_id: current_user.id, username: current_user.username }, expires_in: 30.minutes)
    broadcast(editing: { id: current_user.id, username: current_user.username })
  end

  def stop_editing
    clear_if_current_editor
  end

  private

  def cache_key
    "page_editing:#{params[:page_id]}"
  end

  def broadcast(payload)
    ActionCable.server.broadcast("page_editing_#{params[:page_id]}", payload)
  end

  def clear_if_current_editor
    current = Rails.cache.read(cache_key)
    return unless current && current[:user_id] == current_user.id

    Rails.cache.delete(cache_key)
    broadcast(editing: nil)
  end
end
```
- `start_editing` called by the client when entering edit mode; `stop_editing` on Save/Cancel; `unsubscribed` fires automatically on disconnect (closed tab, crash, network drop) as a fallback, so a stale "being edited" badge can't get stuck forever
- The 30-minute cache expiry is a second fallback in case even `unsubscribed` doesn't fire

**Auth gotcha to flag explicitly**: `current_user` today reads the JWT from the `Authorization` header (`application_controller.rb`), but a browser's native WebSocket API can't set custom headers on the handshake request. `ApplicationCable::Connection#connect` will need to pull the token from the cable URL's query string instead (e.g. `wss://.../cable?token=<jwt>`) and decode it the same way `current_user` does elsewhere. This needs its own small implementation — flagging so it's not missed.

### Open items not covered above

- Nothing else blocking — the answers above cover content format, locking, live updates, ownership semantics, contributors, search, creation flow, and permissions. Ping me if any of the stated assumptions (title uniqueness, no version history, contributor-on-save-only) should be different before you build against this.
