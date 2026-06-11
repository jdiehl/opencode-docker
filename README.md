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
