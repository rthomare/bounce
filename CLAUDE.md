# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Bounce is a cross-platform music sharing app. Users can share songs across streaming platforms (Apple Music, Spotify, YouTube). The repo is a monorepo with two apps:
- **`web/`** — Next.js web application (active development on `rohan/webtransition121825`)
- **`iOS/`** — Native SwiftUI iOS application

## Web App Commands

All commands run from the `web/` directory. Package manager is **Bun**.

```bash
bun install          # Install dependencies
bun run dev          # Start dev server
bun run build        # Production build
bun run start        # Start production server
bun run lint         # Run ESLint
```

No test framework is currently configured.

## Web App Architecture

- **Framework:** Next.js 16 with App Router, React 19, TypeScript (strict mode)
- **Styling:** Tailwind CSS v4 with PostCSS
- **Backend:** Supabase (PostgreSQL + auth via `@supabase/ssr`)
- **Path alias:** `@/*` maps to `web/*`

Key structure:
- `app/` — Next.js App Router pages and layouts (server components by default)
- `utils/supabase/server.ts` — Server-side Supabase client (uses cookies for auth)
- `utils/supabase/client.ts` — Browser-side Supabase client
- Environment variables (`NEXT_PUBLIC_SUPABASE_URL`, `NEXT_PUBLIC_SUPABASE_ANON_KEY`) configured in `.env.local`

## iOS App Architecture

- **Language:** Swift / SwiftUI
- **Project:** `iOS/bounce/bounce.xcodeproj`
- **External API:** SongLink for cross-platform music link resolution

App navigation is state-driven via `AppController` with surfaces: `.loading`, `.home`, `.create`, `.recieve(song:)`.

Key directories under `iOS/bounce/shared/`:
- `general/` — App-level controllers (`AppController`, `BounceApp`)
- `create/` — Song creation/sharing flow (`CreateController`, `CreateView`)
- `recieve/` — Song receiving flow (`ReceiveController`, `RecieveView`)
- `network/` — API layer (`RequestController`, `SongLinkRequest`)
- `models/` — Data models (`Song`, `Consts`)
- `components/` — Reusable UI (`LoaderView`, `ShakeDetector`, `SongEntityView`)
- `utilities/` — Helpers (`ServiceMatcher`, `MessageFactory`)

## Data Model

Defined in `web/DataModel.md`. Core entities: User, ServiceCredential, Bounce (song share), BounceListen, ActivityLog.

## CI/CD

GitHub Actions workflow (`.github/workflows/deploy.yml`) deploys on push to `main`. Note: the workflow currently references a legacy `./webapp` directory and may need updating to point to `./web`.
