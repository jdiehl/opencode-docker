# OpenCode Docker Environment

## Project Purpose
This repository provides a Docker-based environment for running the OpenCode AI agent across multiple isolated projects with shared tooling and caches.

## Architecture

### Key Files
- **Dockerfile** — Creates the `opencode:latest` image with Node.js 22, OpenCode, and dev tools
- **bin/ocbuild** — Builds the Docker image and creates shared volumes (npm-cache, npm-global, pip-cache, pip-packages)
- **bin/oc** — Starts a containerized OpenCode session with a workspace mounted
- **config/opencode.jsonc** — OpenCode configuration (providers, permissions, instructions) copied into containers
- **opencode.jsonc** — Root config specifying enabled AI providers

### How It Works
1. `ocbuild` builds the Docker image and creates named volumes for caching
2. `oc <workspace-path>` launches a container with:
   - Workspace mounted at `/workspace`
   - Shared caches (npm, pip) for reuse across projects
   - AWS credentials from `~/.aws` (read-only)
   - Env vars from `~/.env`
3. OpenCode starts automatically in the container

## Important Notes
- Security permissions in `config/opencode.jsonc` block access to secrets (.env, .aws, .ssh)
- The Docker image includes: Git, Python 3, jq, ripgrep, fzf, pandoc, GitHub CLI, Atlassian CLI
- All npm/pip packages are cached in named volumes to speed up subsequent runs

## Session Persistence
OpenCode sessions are automatically persisted across Docker container restarts via the `opencode-data` named volume. This means:
- Session history and state survive container exits
- Sessions are globally shared (available across all projects)
- Use `opencode session list` to view available sessions
- Use `opencode --continue` to resume the last session
- Use `opencode --session <ID>` to resume a specific session

## Common Tasks
- **Build image:** `bash bin/ocbuild`
- **Run OpenCode:** `bash bin/oc <workspace-path>`
- **Resume last session:** `bash bin/oc <workspace-path> --continue`
- **Resume specific session:** `bash bin/oc <workspace-path> --session <sessionID>`
- **Add tools to Dockerfile:** Modify the apt-get install section in Dockerfile, rebuild with ocbuild
