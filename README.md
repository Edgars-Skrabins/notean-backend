# Notean backend

This is the backend project for the Notean app. It's a Rails API used together with the [notean frontend](../frontend) — the frontend won't work without this running.

## Prerequisites

- Ruby 3.3.5 (see `.ruby-version`)
- Bundler (`gem install bundler`)
- `config/master.key` — required to decrypt `config/credentials.yml.enc` (needed for JWT signing). This file is gitignored and not part of the repo, so get it from a teammate and place it at `config/master.key`. Without it, the server will fail on requests that touch auth.

## Setup

1. Install dependencies:
   ```
   bundle install
   ```
2. Create and migrate the database:
   ```
   bin/rails db:migrate
   ```

## Running the backend

```
bin/rails server
```

The API will be available at `http://127.0.0.1:3000`.

## Running the full app (backend + frontend)

1. Start this backend first (see above) — it must be running at `http://127.0.0.1:3000`.
2. In a separate terminal, set up and start the [frontend](../frontend) — see its README.

## Running tests

```
bin/rails test
```
