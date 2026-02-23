#!/usr/bin/env bash

set -euo pipefail

REPO="soxhub/bootstrap"
INSTALL_DIR="${HOME}/.local/bin"
ABC_VERSION="${ABC_VERSION:-latest}"

log() {
  echo "[bootstrap] $*"
}

require_macos() {
  if [[ "$(uname -s)" != "Darwin" ]]; then
    log "This installer currently supports macOS only."
    exit 1
  fi
}

detect_asset_name() {
  local arch
  arch="$(uname -m)"

  case "$arch" in
    arm64)
      echo "abc-darwin-arm64"
      ;;
    x86_64)
      echo "abc-darwin-x64"
      ;;
    *)
      log "Unsupported CPU architecture: $arch"
      exit 1
      ;;
  esac
}

ensure_devbox() {
  if command -v devbox >/dev/null 2>&1; then
    log "Devbox already installed"
    return
  fi

  log "Installing Devbox..."
  curl -fsSL https://get.jetify.com/devbox | bash
  log "Devbox installed"
}

install_abc_from_release() {
  local asset_name
  local download_url
  local target
  local release_ref

  asset_name="$(detect_asset_name)"

  if [[ "$ABC_VERSION" == "latest" ]]; then
    release_ref="latest"
    download_url="https://github.com/${REPO}/releases/latest/download/${asset_name}"
  else
    if [[ "$ABC_VERSION" =~ ^v ]]; then
      release_ref="$ABC_VERSION"
    else
      release_ref="v${ABC_VERSION}"
    fi
    download_url="https://github.com/${REPO}/releases/download/${release_ref}/${asset_name}"
  fi

  mkdir -p "$INSTALL_DIR"
  target="${INSTALL_DIR}/abc"

  log "Downloading ${asset_name} from ${REPO} release ${release_ref}..."
  if ! curl -fL "$download_url" -o "$target"; then
    log "Failed to download abc from release assets."
    log "Expected URL: ${download_url}"
    log "Make sure ${REPO} has a release with asset ${asset_name}."
    exit 1
  fi

  chmod +x "$target"
  log "Installed abc to ${target}"
}

print_path_hint() {
  case ":$PATH:" in
    *":${INSTALL_DIR}:"*)
      ;;
    *)
      log "Add ${INSTALL_DIR} to PATH if needed:"
      log "  echo 'export PATH=\"${INSTALL_DIR}:$PATH\"' >> ~/.zshrc"
      ;;
  esac
}

main() {
  require_macos
  log "Starting AuditBoard bootstrap"
  log "Requested abc version: ${ABC_VERSION}"

  ensure_devbox

  if command -v abc >/dev/null 2>&1; then
    log "abc already installed at $(command -v abc)"
  else
    install_abc_from_release
  fi

  print_path_hint

  if command -v abc >/dev/null 2>&1; then
    log "abc version: $(abc --version)"
    log "Next step: run 'abc init'"
  else
    log "abc is not on PATH in this shell yet."
    log "Run: ${INSTALL_DIR}/abc --version"
    log "Then run: ${INSTALL_DIR}/abc init"
  fi
}

main "$@"
