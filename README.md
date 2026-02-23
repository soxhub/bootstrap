# AuditBoard Bootstrap

This repo is the public bootstrap entrypoint.

## Quickstart (new machine)

1. Install Devbox

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

2. Install `abc`

```bash
curl -fsSL https://raw.githubusercontent.com/soxhub/bootstrap/main/bootstrap.sh | bash
```

Optional: install a pinned `abc` version:

```bash
ABC_VERSION=v1.9.0 curl -fsSL https://raw.githubusercontent.com/soxhub/bootstrap/main/bootstrap.sh | bash
```

3. Verify

```bash
abc --version
```

4. Initialize dev environment

```bash
abc init
```

## Notes

- This bootstrap flow is intentionally minimal: install Devbox first, then `abc`.
- The installer script downloads `abc` from `soxhub/bootstrap` release assets.
- Releases are versioned by tag (for example `v1.9.0`) and can be pinned via `ABC_VERSION`.
- On macOS, binaries are expected to be named:
  - `abc-darwin-arm64`
  - `abc-darwin-x64`

