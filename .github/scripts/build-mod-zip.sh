#!/usr/bin/env bash
#
# Build the release zip for David Sandevistan Plus.
#
# Called by semantic-release via the @semantic-release/exec prepareCmd.
# Receives the next release version as $1 (e.g. "1.0.0" or "1.0.0-beta.1").
# Writes the zip to dist/DavidSandevistanPlus-v<version>.zip.
#
# What goes in the zip:
#   archive/pc/mod/   - the .archive + .archive.xl pair
#   bin/x64/...       - CET Lua mod folder + localization
#   r6/scripts/...    - redscript files (DSP + bundled AnimatedWidgets)
#   r6/tweaks/...     - TweakXL YAML (immunoblocker items, vendors, cyberware)
#   r6/audioware/...  - Audioware yaml + last_breath_song + sfx + 136 voice lines
#
# What stays out:
#   wolven/            - WolvenKit project sources (cooked into the archive already)
#   mods/              - intermediate voice synthesis artefacts
#   voice_lines/       - source data for voice generation
#   tools/             - dev scripts (redscript bisect, etc.)
#   docs/              - design docs, SVGs, BBCode description
#   .github/, .claude/ - repo tooling, not for end users
#   __pycache__/, *.py - voice generation pipeline
#   CLAUDE.md          - agent instructions
#   *.bbcode           - Nexus description source
#   LICENSE, README.md - shipped via the Nexus page, not bundled
#
set -euo pipefail

VERSION="${1:?version required (e.g. 1.0.0 or 1.0.0-beta.1)}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DIST_DIR="${REPO_ROOT}/dist"
ZIP_NAME="DavidSandevistanPlus-v${VERSION}.zip"
ZIP_PATH="${DIST_DIR}/${ZIP_NAME}"

echo "[build] version: ${VERSION}"
echo "[build] zip:     ${ZIP_PATH}"

# Required top-level dirs. If any is missing, fail loudly so the release does
# not ship an incomplete bundle.
REQUIRED_DIRS=(
  "archive/pc/mod"
  "bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus"
  "r6/scripts/DavidSandevistanPlus"
  "r6/scripts/AnimatedWidgets"
  "r6/tweaks/DavidSandevistanPlus"
  "r6/audioware/DavidSandevistanPlus"
)
for d in "${REQUIRED_DIRS[@]}"; do
  if [[ ! -d "${REPO_ROOT}/${d}" ]]; then
    echo "[build] FATAL: required directory missing: ${d}" >&2
    exit 1
  fi
done

# Sanity check: voice files vs audios.yaml entries. Skip if jq / yq unavailable.
VOICE_DIR="${REPO_ROOT}/r6/audioware/DavidSandevistanPlus/voice/v_male"
AUDIOS_YAML="${REPO_ROOT}/r6/audioware/DavidSandevistanPlus/audios.yaml"
if [[ -d "${VOICE_DIR}" && -f "${AUDIOS_YAML}" ]]; then
  voice_files=$(find "${VOICE_DIR}" -name "*.ogg" | wc -l)
  yaml_voice_entries=$(grep -c "^  dsp_vm_" "${AUDIOS_YAML}" || true)
  echo "[build] voice files: ${voice_files}, yaml entries: ${yaml_voice_entries}"
  if [[ "${voice_files}" != "${yaml_voice_entries}" ]]; then
    echo "[build] WARNING: voice file count (${voice_files}) != audios.yaml entries (${yaml_voice_entries})" >&2
  fi
fi

mkdir -p "${DIST_DIR}"
rm -f "${ZIP_PATH}"

# Build the zip from the repo root, preserving the on-disk structure so
# extracting into a Cyberpunk install lands every path where the game
# expects it. Exclusions strip dev junk that ends up under tracked dirs
# (backup files, OS metadata, cached bytecode).
cd "${REPO_ROOT}"
zip -r "${ZIP_PATH}" \
  archive/pc/mod \
  bin/x64/plugins/cyber_engine_tweaks/mods/DavidSandevistanPlus \
  r6/scripts/DavidSandevistanPlus \
  r6/scripts/AnimatedWidgets \
  r6/tweaks/DavidSandevistanPlus \
  r6/audioware/DavidSandevistanPlus \
  -x "*.bak" \
  -x "*.DS_Store" \
  -x "__pycache__/*" \
  -x "**/__pycache__/*" \
  -x "*.pyc" \
  -x "**/*.log" \
  > /dev/null

size=$(du -h "${ZIP_PATH}" | cut -f1)
file_count=$(unzip -l "${ZIP_PATH}" | tail -1 | awk '{print $2}')
echo "[build] done: ${ZIP_PATH} (${size}, ${file_count} files)"
