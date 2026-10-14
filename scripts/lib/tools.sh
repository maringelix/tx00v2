# shellcheck shell=bash
# Download metadata for every harness tool (official release URLs only).
# Used by scripts/install-tools.sh and scripts/update-tool-checksums.sh. The versions shared with the
# six lab repositories stay equal to theirs (the family check family-versions compares them).

# Install order; also the list accepted by both scripts.
# shellcheck disable=SC2034 # used by the scripts that source this file
TOOLS_ALL=(actionlint shellcheck gitleaks jq)
# shellcheck disable=SC2034
TOOLS_PLATFORMS=(linux_amd64 linux_arm64 darwin_arm64)

# tools_platform -> linux_amd64 | linux_arm64 | darwin_arm64 for the current machine.
tools_platform() {
  local os arch
  case "$(uname -s)" in
    Linux) os=linux ;;
    Darwin) os=darwin ;;
    *) die "unsupported OS '$(uname -s)'; use WSL 2 or the Docker one-liner of docs/HARNESS.md." ;;
  esac
  case "$(uname -m)" in
    x86_64 | amd64) arch=amd64 ;;
    aarch64 | arm64) arch=arm64 ;;
    *) die "unsupported CPU architecture '$(uname -m)'." ;;
  esac
  case "${os}_${arch}" in
    linux_amd64 | linux_arm64 | darwin_arm64) printf '%s_%s' "$os" "$arch" ;;
    *) die "unsupported platform ${os}_${arch} (supported: ${TOOLS_PLATFORMS[*]})." ;;
  esac
}

# tool_known TOOL -> success when TOOL is managed by these scripts.
tool_known() {
  local t
  for t in "${TOOLS_ALL[@]}"; do
    [[ "$t" == "$1" ]] && return 0
  done
  return 1
}

# tool_artifact TOOL VERSION PLATFORM -> release artifact file name.
tool_artifact() {
  local tool=$1 v=$2 p=$3 x
  case "$tool" in
    actionlint) printf 'actionlint_%s_%s.tar.gz' "$v" "$p" ;;
    shellcheck)
      case "$p" in
        linux_amd64) x=linux.x86_64 ;;
        linux_arm64) x=linux.aarch64 ;;
        darwin_arm64) x=darwin.aarch64 ;;
      esac
      printf 'shellcheck-v%s.%s.tar.xz' "$v" "$x"
      ;;
    gitleaks)
      x=$p
      [[ "$p" == linux_amd64 ]] && x=linux_x64
      printf 'gitleaks_%s_%s.tar.gz' "$v" "$x"
      ;;
    jq)
      case "$p" in
        linux_amd64) x=linux-amd64 ;;
        linux_arm64) x=linux-arm64 ;;
        darwin_arm64) x=macos-arm64 ;;
      esac
      printf 'jq-%s' "$x"
      ;;
    *) die "unknown tool: $tool" ;;
  esac
}

# tool_url TOOL VERSION PLATFORM -> official download URL of the artifact.
tool_url() {
  local tool=$1 v=$2 p=$3 a gh=https://github.com
  a="$(tool_artifact "$tool" "$v" "$p")"
  case "$tool" in
    actionlint) printf '%s/rhysd/actionlint/releases/download/v%s/%s' "$gh" "$v" "$a" ;;
    shellcheck) printf '%s/koalaman/shellcheck/releases/download/v%s/%s' "$gh" "$v" "$a" ;;
    gitleaks) printf '%s/gitleaks/gitleaks/releases/download/v%s/%s' "$gh" "$v" "$a" ;;
    jq) printf '%s/jqlang/jq/releases/download/jq-%s/%s' "$gh" "$v" "$a" ;;
    *) die "unknown tool: $tool" ;;
  esac
}

# tool_checksum_url TOOL VERSION PLATFORM -> URL of the upstream checksum file of that exact release,
# or nothing when upstream publishes none (shellcheck).
tool_checksum_url() {
  local tool=$1 v=$2 gh=https://github.com
  case "$tool" in
    actionlint) printf '%s/rhysd/actionlint/releases/download/v%s/actionlint_%s_checksums.txt' "$gh" "$v" "$v" ;;
    shellcheck) ;;
    gitleaks) printf '%s/gitleaks/gitleaks/releases/download/v%s/gitleaks_%s_checksums.txt' "$gh" "$v" "$v" ;;
    jq) printf '%s/jqlang/jq/releases/download/jq-%s/sha256sum.txt' "$gh" "$v" ;;
    *) die "unknown tool: $tool" ;;
  esac
}

# tool_expected_sha TOOL VERSION PLATFORM -> SHA256 recorded in tools/checksums.txt.
tool_expected_sha() {
  awk -v t="$1" -v v="$2" -v p="$3" '!/^#/ && NF == 4 && $2 == t && $3 == v && $4 == p { print $1; exit }' \
    "$REPO_ROOT/tools/checksums.txt"
}

# tool_extract TOOL VERSION PLATFORM ARCHIVE TOOLS_DIR -> installs the binary from ARCHIVE.
tool_extract() {
  local tool=$1 v=$2 archive=$4 tools_dir=$5 work src
  work="$(mktemp -d)"
  case "$archive" in
    *.tar.gz) tar -xzf "$archive" -C "$work" ;;
    *.tar.xz) tar -xJf "$archive" -C "$work" ;;
    *) cp "$archive" "$work/$tool" ;;
  esac
  case "$tool" in
    shellcheck) src="$work/shellcheck-v$v/shellcheck" ;;
    *) src="$work/$tool" ;;
  esac
  [[ -f "$src" ]] || die "binary for $tool not found inside $(basename "$archive")"
  mkdir -p "$tools_dir/bin"
  install -m 0755 "$src" "$tools_dir/bin/$tool"
  rm -rf "$work"
}

# tool_installed_path TOOL TOOLS_DIR -> path of the installed binary.
tool_installed_path() {
  printf '%s/bin/%s' "$2" "$1"
}
