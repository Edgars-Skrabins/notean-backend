# Backend TODO

User accounts + auth endpoints (`User` model, `UsersController`, `SessionsController`, `JsonWebToken`, `POST /auth/register`, `POST /auth/login`) are done and pushed to master.

Team model + endpoints (`Team`/`Membership` models, `TeamsController`, `POST /teams`, `GET /teams/:code`, `POST /actions/jointeam`) are done. Team creation takes `{ team: { name, password } }` — the server generates a unique 32-character `code` and returns it in the response; the client never supplies a code on create, only on join.

## 1. User <-> Team membership — partially done

- Membership join table exists (`user_id`, `team_id`, `role`) and is populated on create (`owner`) and join (`member`)
- Still missing: endpoint to list the current user's teams, and to leave a team
- (Not yet needed by the frontend, but coming soon) per-team roles beyond owner/member — viewer/admin, and permission checks based on role

## 2. Team-scoped data — not started

- Each team will need its own data (notes, kanban board, etc.) — scope/shape still TBD, revisit once that's decided
