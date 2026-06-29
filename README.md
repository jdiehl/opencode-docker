# OpenCode Docker

Run OpenCode in lightweight, isolated Docker containers with shared caching and session persistence.

## Installation

1. Add `bin` to your PATH by adding this line to your `~/.zshrc` (replace `/path/to/opencode-docker` with the actual project path):
```bash
export PATH="$PATH:/path/to/opencode-docker/bin"
```

2. Build the Docker image:
```bash
ocbuild
```
Run this again when updating the project.

3. Run OpenCode in any folder:
```bash
oc
```
Or specify a workspace:
```bash
oc ~/path/to/workspace
```

## Usage

The current directory (or provided path) is automatically mounted as `/workspace` inside the container.

### Additional volumes
Mount extra directories:
```bash
oc -v ~/shared/docs:/workspace/docs ~/workspace
```

### Profiles
Separate configurations and session history for different use cases:
```bash
oc -p work ~/work-stuff
oc -p personal ~/private-stuff
```

### Global packages
npm and pip packages persist across sessions when installed globally:
```bash
npm install -g my-tool
pip install --user my-package
```

These are automatically cached and available in future sessions.

### OpenCode parameters
Pass OpenCode parameters as usual:
```bash
oc ~/workspace --continue
oc ~/workspace --session <sessionID>
```

## Security

- **AWS credentials** — `~/.aws` is mounted read-only to enable Bedrock usage. To disable, edit `bin/oc`
- **Protected paths** — Access to `.env`, `.aws`, `.ssh` is blocked from OpenCode

## Troubleshooting

### `Permission denied` on `/workspace` (or any host bind mount)

If the container can list `$HOME` fine but `~/Documents`, `~/Downloads`, or `~/Desktop` fail with `Permission denied` — even when running as root — the cause is **macOS TCC (Transparency, Consent, and Control)**, not Linux permissions. The macOS kernel blocks the read at the file-sharing layer (colima's `sshfs`/`virtiofs`) before it reaches the container.

Fix:

1. **System Settings → Privacy & Security → Full Disk Access** and grant access to your terminal app (`Terminal.app`, `iTerm2`, etc.) and/or `colima`.
2. Quit the terminal completely (Cmd-Q), then `colima stop && colima start` so the file-sharing connection re-establishes with the new permission.

Bind mounts under `~` (not inside a TCC-protected subfolder) keep working without this change.
