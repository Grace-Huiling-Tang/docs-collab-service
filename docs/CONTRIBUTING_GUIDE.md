# Contributing Guide

## Branching
- Work on a branch (no direct commits to `main`).
- Naming convention:
  - `feature/<scope>-<short-desc>` (new features)
  - `fix/<scope>-<short-desc>` (bug fixes)
  - `docs/<short-desc>` (documentation)
  - `chore/<short-desc>` (tooling/CI/maintenance)
- Examples:
  - `feature/auth-register-login`
  - `feature/rbac-membership`
  - `docs/erd`
  - `chore/ci-github-actions`

## Workflow (recommended)
1. Sync main:
   - `git checkout main && git pull origin main`
2. Create a branch:
   - `git checkout -b <branch-name>`
3. Commit small, focused changes (one topic per PR).
4. Push and open a Pull Request (PR) to `main`.
5. Merge only when:
   - CI checks are green ✅ (`./mvnw test` in GitHub Actions)
   - No unresolved review comments (if reviews are required)

## CI / Quality Gates
- CI runs `./mvnw test` on PRs.
- Do not merge PRs with failing checks.

## Database migrations (Flyway)
- Never edit an already-applied migration on `main`.
- Add new changes via a new migration: `V<next>__<description>.sql`
- Keep migrations deterministic: fresh DB should migrate from V1 to latest without manual steps.

## After merge
- Delete the branch after merging to keep the repo clean:
  - GitHub: click **Delete branch** on the PR page
  - Local: `git branch -d <branch-name>`
