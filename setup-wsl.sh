#!/usr/bin/env bash

# Run only if setting up new WSL/Linux Environment.  
# Purpose: Install the pinned Hugo Extended version and verify that this site's
# Stack theme submodule matches the expected version and commit in WSL.
# Hugo and stack versions recorded and pinned on 10/03/2026.
# This helps maintain a working setup when transitioning to a new PC by ensuring compatibility. 
# Ubuntu's package repositories (frozen per Ubuntu release) can lag behind the latest releases. 
# Git installation and repository cloning are documented below, but are manual.

set -euo pipefail

# One-time manual setup on a new WSL machine:
#   sudo apt update && sudo apt install -y git
#   mkdir -p /mnt/c/Users/Gauri/Documents/sites
#   git clone --recurse-submodules \
#     https://github.com/guptg/guptg.github.io.git \
#     /mnt/c/Users/Gauri/Documents/sites/my-site
#   cd /mnt/c/Users/Gauri/Documents/sites/my-site
#
# Then run: bash setup-wsl.sh

readonly PROJECT_DIR="/mnt/c/Users/Gauri/Documents/sites/my-site"
readonly HUGO_VERSION="0.166.0"
readonly HUGO_BIN="${HOME}/.local/bin/hugo"
readonly THEME_DIR="${PROJECT_DIR}/themes/hugo-theme-stack"
readonly THEME_VERSION="v4.0.3"
readonly THEME_COMMIT="3e123a30b79b5d52a3a8e88a9dd678fcfd28e418"

if ! command -v git >/dev/null 2>&1; then
  echo "Git is not installed. Uncomment and run the apt install command at the top of this script, then rerun it." >&2
  exit 1
fi

case "$(uname -s)" in
  Linux) ;;
  *)
    echo "This script installs the Linux Hugo build and must be run in WSL/Linux." >&2
    exit 1
    ;;
esac

case "$(uname -m)" in
  x86_64 | amd64) HUGO_ARCH="amd64" ;;
  aarch64 | arm64) HUGO_ARCH="arm64" ;;
  *)
    echo "Unsupported machine architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

mkdir -p "${HOME}/.local/bin"

installed_hugo_version=""
if [[ -x "${HUGO_BIN}" ]]; then
  installed_hugo_version="$("${HUGO_BIN}" version 2>/dev/null || true)"
fi

if [[ "${installed_hugo_version}" != "hugo v${HUGO_VERSION}-"* ||
      "${installed_hugo_version}" != *"+extended"* ]]; then
  archive="hugo_extended_${HUGO_VERSION}_linux-${HUGO_ARCH}.tar.gz"
  url="https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${archive}"
  temp_dir="$(mktemp -d)"
  trap 'rm -rf "${temp_dir}"' EXIT

  if command -v curl >/dev/null 2>&1; then
    curl --fail --location --output "${temp_dir}/${archive}" "${url}"
  elif command -v wget >/dev/null 2>&1; then
    wget --output-document="${temp_dir}/${archive}" "${url}"
  else
    echo "Neither curl nor wget is installed; install one and rerun this script." >&2
    exit 1
  fi

  tar -xzf "${temp_dir}/${archive}" -C "${temp_dir}" hugo
  install -m 0755 "${temp_dir}/hugo" "${HUGO_BIN}"
fi

path_line='export PATH="$HOME/.local/bin:$PATH"'
if [[ ! -f "${HOME}/.bashrc" ]] || ! grep -Fqx "${path_line}" "${HOME}/.bashrc"; then
  printf '\n%s\n' "${path_line}" >> "${HOME}/.bashrc"
fi
export PATH="${HOME}/.local/bin:${PATH}"

hugo_output="$("${HUGO_BIN}" version)"
if [[ "${hugo_output}" != "hugo v${HUGO_VERSION}-"* ||
      "${hugo_output}" != *"+extended"* ]]; then
  echo "Hugo verification failed. Expected v${HUGO_VERSION} Extended; got: ${hugo_output}" >&2
  exit 1
fi
printf 'Hugo verified: %s\n' "${hugo_output}"

if [[ ! -d "${PROJECT_DIR}" ]]; then
  echo "Project directory not found: ${PROJECT_DIR}" >&2
  exit 1
fi
if ! git -C "${THEME_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Stack theme submodule is missing or uninitialized: ${THEME_DIR}" >&2
  echo "Clone with --recurse-submodules, or run: git submodule update --init --recursive" >&2
  exit 1
fi

theme_commit="$(git -C "${THEME_DIR}" rev-parse HEAD)"
theme_version="$(git -C "${THEME_DIR}" describe --tags --exact-match HEAD 2>/dev/null || true)"
if [[ "${theme_commit}" != "${THEME_COMMIT}" || "${theme_version}" != "${THEME_VERSION}" ]]; then
  echo "Stack verification failed." >&2
  echo "Expected ${THEME_VERSION} (${THEME_COMMIT}); got ${theme_version:-untagged} (${theme_commit})." >&2
  exit 1
fi
printf 'Stack verified: %s (%s)\n' "${theme_version}" "${theme_commit}"

# Optional site-build verification:
# From the project directory, run:
#   hugo --gc --minify
# A successful build exits with status 0 and generates the site in public/.
