#!/usr/bin/env bash

set -Eeuo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "${SCRIPT_DIR}/common.sh"

require_command curl
require_command sha256sum

case "$(uname -s)" in
  Linux) os=linux ;;
  Darwin) os=darwin ;;
  *) fail "Install kind from WSL/Linux or macOS for this lab." ;;
esac

case "$(uname -m)" in
  x86_64|amd64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  *) fail "Unsupported architecture: $(uname -m)" ;;
esac

asset="kind-${os}-${arch}"
url="https://kind.sigs.k8s.io/dl/${KIND_VERSION}/${asset}"
destination="${REPO_ROOT}/.local/bin/kind"
temporary_directory="$(mktemp -d)"
trap 'rm -rf "${temporary_directory}"' EXIT

log "Downloading kind ${KIND_VERSION} for ${os}/${arch}"
curl -fsSLo "${temporary_directory}/${asset}" "${url}"
curl -fsSLo "${temporary_directory}/${asset}.sha256sum" "${url}.sha256sum"
(
  cd "${temporary_directory}"
  sha256sum -c "${asset}.sha256sum"
)

mkdir -p "$(dirname "${destination}")"
install -m 0755 "${temporary_directory}/${asset}" "${destination}"

log "Installed $(${destination} version) at ${destination}"
