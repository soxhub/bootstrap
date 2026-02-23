{
  description = "AuditBoard bootstrap flake";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { nixpkgs, ... }:
    let
      systems = [ "aarch64-darwin" "x86_64-darwin" "aarch64-linux" "x86_64-linux" ];
      forAllSystems = f:
        nixpkgs.lib.genAttrs systems (
          system:
          f (import nixpkgs { inherit system; })
        );
    in
    {
      packages = forAllSystems (pkgs: rec {
        abc = pkgs.writeShellScriptBin "abc" ''
          set -euo pipefail

          REPO="soxhub/bootstrap"
          ABC_VERSION="''${ABC_VERSION:-latest}"
          CACHE_DIR="''${XDG_CACHE_HOME:-$HOME/.cache}/soxhub-bootstrap"
          TARGET="''${CACHE_DIR}/abc"
          VERSION_FILE="''${CACHE_DIR}/version"

          case "$(uname -s):$(uname -m)" in
            Darwin:arm64)
              ASSET_NAME="abc-darwin-arm64"
              ;;
            Darwin:x86_64)
              ASSET_NAME="abc-darwin-x64"
              ;;
            *)
              echo "[abc] unsupported platform: $(uname -s) $(uname -m)" >&2
              exit 1
              ;;
          esac

          if [[ "$ABC_VERSION" == "latest" ]]; then
            DOWNLOAD_URL="https://github.com/''${REPO}/releases/latest/download/''${ASSET_NAME}"
            REQUESTED_VERSION="latest"
          else
            if [[ "$ABC_VERSION" =~ ^v ]]; then
              REQUESTED_VERSION="$ABC_VERSION"
            else
              REQUESTED_VERSION="v''${ABC_VERSION}"
            fi
            DOWNLOAD_URL="https://github.com/''${REPO}/releases/download/''${REQUESTED_VERSION}/''${ASSET_NAME}"
          fi

          mkdir -p "$CACHE_DIR"

          INSTALLED_VERSION=""
          if [[ -f "$VERSION_FILE" ]]; then
            INSTALLED_VERSION="$(cat "$VERSION_FILE")"
          fi

          if [[ ! -x "$TARGET" || "$INSTALLED_VERSION" != "$REQUESTED_VERSION" ]]; then
            echo "[abc] downloading ''${ASSET_NAME} (''${REQUESTED_VERSION})..."
            TMP_TARGET="''${TARGET}.tmp"
            ${pkgs.curl}/bin/curl -fL "$DOWNLOAD_URL" -o "$TMP_TARGET"
            chmod +x "$TMP_TARGET"
            mv "$TMP_TARGET" "$TARGET"
            echo "$REQUESTED_VERSION" > "$VERSION_FILE"
          fi

          exec "$TARGET" "$@"
        '';

        default = abc;
      });
    };
}
