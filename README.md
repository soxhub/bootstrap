# AuditBoard Bootstrap

This repo is the public bootstrap entrypoint.

## Quickstart (new machine)

1. Install Devbox

```bash
curl -fsSL https://get.jetify.com/devbox | bash
```

2. Install `abc` globally from this flake

```bash
devbox global add github:soxhub/bootstrap#abc
```

## One-time shell setup for Devbox globals

Run this once to load Devbox global binaries in your current shell and future shells:

```bash
eval "$(devbox global shellenv)"
grep -q 'devbox global shellenv' ~/.zshrc || echo 'eval "$(devbox global shellenv)"' >> ~/.zshrc
```

## Verify

```bash
abc --version
```

## Initialize dev environment

```bash
abc init
```

## Optional: pin abc version

By default, `abc` resolves to the latest bootstrap release binary on first run.
To pin a version for download, set `ABC_VERSION`:

```bash
ABC_VERSION=v1.9.0 abc --version
```

