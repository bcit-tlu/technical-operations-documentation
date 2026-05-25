# AGENTS.md

## Setup Commands

- Local development: `docker compose up` (starts Zensical dev server on port 8000)
- Helm lint: `helm lint charts/tech-ops-docs/`
- Helm validate: `helm template test charts/tech-ops-docs/ | kubeconform -strict -summary -schema-location default -ignore-missing-schemas`

## Code Style

- Documentation is written in Markdown under `docs/`
- Site is built with Zensical (configured in `zensical.toml`)
- Follow conventional commit format for PR titles
- License: MPL-2.0

## Project Structure

- `/docs` — Markdown source files for technical guides and architecture
- `/charts/tech-ops-docs/` — Helm chart for Kubernetes deployment (nested layout)
- `/.github/workflows/` — CI/CD pipelines
- `/conf.d/` — Nginx configuration for serving the static site
- `/zensical.toml` — Static site generator configuration and navigation
- `/Dockerfile` — Multi-stage build: Zensical builder to nginx-unprivileged runtime

## Architecture

- **Build**: Zensical (Python SSG) renders Markdown to static HTML
- **Runtime**: nginx-unprivileged serving static files on port 8080
- **Health endpoint**: `GET /` returns 200

## Development Workflow

- Create feature branches from `main`
- Use pull requests for code review
- PR titles must follow conventional commit format (enforced by `pr-title-lint.yaml`)
- Squash commits before merging

## CI/CD

- CI uses shared `bcit-tlu/.github` OCI build reusable workflow
- `helm-lint` validates Helm charts on every push and PR
- `release-please` manages versioning via conventional commits (`release-type: "simple"`)
- Chart `version:` is hand-maintained; only `appVersion:` is managed by release-please (`# x-release-please-version`)
- Images are published to `ghcr.io/bcit-tlu/technical-operations-documentation/tech-ops-docs`
- Charts are published to `oci://ghcr.io/bcit-tlu/technical-operations-documentation/charts`
- `FORCE_JAVASCRIPT_ACTIONS_TO_NODE24: true` is set in all workflows

## Deployment

- Deployed to Kubernetes via Flux CD (see `bcit-tlu/flux-fleet`)
- Served by nginx-unprivileged on port 8080
