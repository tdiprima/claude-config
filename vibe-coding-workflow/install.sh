#!/usr/bin/env bash
#
# install.sh - Install the review skills and agents for Claude Code and Codex.
#
# What it installs (for code-review, security-review, test-review, architecture-review):
#   <codex dir>/skills/<name>/          Skill instructions (the single source of truth)
#   <claude dir>/skills/<name>          Symlink to the Codex skill, so both tools share one copy
#   <claude dir>/agents/<name>.md       Claude Code subagent wrapper
#   <codex dir>/agents/<name>.toml      Codex agent role wrapper
#
# Expects: to run from anywhere; source files live next to this script.
# Config dirs: $CLAUDE_CONFIG_DIR (default ~/.claude) and $CODEX_HOME (default ~/.codex).
# Produces: the files above. Existing files that differ are left alone unless --force is
# given, in which case they are backed up to <file>.bak.<timestamp> first.
#
# Usage: ./install.sh [--dry-run] [--force] [--help]

set -o nounset
set -o pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
readonly SCRIPT_DIR
readonly REVIEW_NAMES=(code-review security-review test-review architecture-review)
readonly CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-${HOME}/.claude}"
readonly CODEX_DIR="${CODEX_HOME:-${HOME}/.codex}"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
readonly TIMESTAMP

readonly EXIT_OK=0
readonly EXIT_USAGE=1
readonly EXIT_MISSING_SOURCE=2
readonly EXIT_CONFLICTS=3
readonly EXIT_WRITE_FAILED=4

is_dry_run=false
is_force=false
conflict_count=0
render_dir=""

# Print an informational message to stdout.
log_info() {
    echo "INFO: $*"
}

# Print a warning to stderr.
log_warn() {
    echo "WARN: $*" >&2
}

# Print an error to stderr.
log_error() {
    echo "ERROR: $*" >&2
}

# Print usage help.
usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run] [--force] [--help]

Install the review skills and agents for Claude Code and Codex.

Options:
  --dry-run   Show what would change without writing anything.
  --force     Replace existing files that differ (originals are backed up first).
  --help, -h  Show this help.

Target directories:
  Claude: ${CLAUDE_DIR}  (override with CLAUDE_CONFIG_DIR)
  Codex:  ${CODEX_DIR}  (override with CODEX_HOME)
EOF
}

# Parse command-line flags into global settings.
parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run)
                is_dry_run=true
                ;;
            --force)
                is_force=true
                ;;
            --help | -h)
                usage
                exit "${EXIT_OK}"
                ;;
            *)
                log_error "unknown option: $1"
                usage >&2
                exit "${EXIT_USAGE}"
                ;;
        esac
        shift
    done
}

# Remove the temporary render directory on exit.
cleanup() {
    if [[ -n "${render_dir}" && -d "${render_dir}" ]]; then
        rm -r "${render_dir}"
    fi
}

# Fail fast if any source file this script needs is missing.
validate_sources() {
    local name
    local source_file
    local is_missing=false

    for name in "${REVIEW_NAMES[@]}"; do
        for source_file in \
            "${SCRIPT_DIR}/skills/${name}/SKILL.md" \
            "${SCRIPT_DIR}/skills/${name}/agents/openai.yaml" \
            "${SCRIPT_DIR}/agents/claude/${name}.md" \
            "${SCRIPT_DIR}/agents/codex/${name}.toml"; do
            if [[ ! -f "${source_file}" ]]; then
                log_error "source file not found: ${source_file}"
                is_missing=true
            fi
        done
    done

    if [[ "${is_missing}" == true ]]; then
        exit "${EXIT_MISSING_SOURCE}"
    fi
}

# Run a command, or only describe it in dry-run mode. Exits if the command fails.
run_write() {
    local description="$1"
    shift

    if [[ "${is_dry_run}" == true ]]; then
        log_info "would ${description}"
        return
    fi

    if ! "$@"; then
        log_error "failed to ${description}"
        exit "${EXIT_WRITE_FAILED}"
    fi
    log_info "${description}"
}

# Decide whether an existing, different target may be replaced. Backs it up when --force is set.
# Returns 0 if the caller should write the target, 1 if it should skip.
make_room_for() {
    local target="$1"

    if [[ ! -e "${target}" && ! -L "${target}" ]]; then
        return 0
    fi

    if [[ "${is_force}" != true ]]; then
        log_warn "exists and differs, skipped (use --force to replace): ${target}"
        conflict_count=$((conflict_count + 1))
        return 1
    fi

    # WORKAROUND: short flags (-p, -s) are used below because macOS BSD tools lack long forms.
    run_write "back up ${target} to ${target}.bak.${TIMESTAMP}" \
        mv "${target}" "${target}.bak.${TIMESTAMP}"
    return 0
}

# Copy one file to its target, creating the parent directory. Skips identical files.
install_file() {
    local source_file="$1"
    local target="$2"

    if [[ -f "${target}" && ! -L "${target}" ]] && cmp -s "${source_file}" "${target}"; then
        log_info "unchanged: ${target}"
        return
    fi

    if ! make_room_for "${target}"; then
        return
    fi

    run_write "create directory $(dirname "${target}")" mkdir -p "$(dirname "${target}")"
    run_write "install ${target}" cp "${source_file}" "${target}"
}

# Escape a string so sed can use it as literal replacement text.
escape_for_sed() {
    printf '%s' "$1" | sed 's/[\\&#]/\\&/g'
}

# Fill in the {{CLAUDE_DIR}} and {{CODEX_DIR}} placeholders, then install the result.
install_template() {
    local source_file="$1"
    local target="$2"
    local rendered_file
    local claude_dir_escaped
    local codex_dir_escaped

    rendered_file="${render_dir}/$(basename "${target}")"
    claude_dir_escaped="$(escape_for_sed "${CLAUDE_DIR}")"
    codex_dir_escaped="$(escape_for_sed "${CODEX_DIR}")"

    if ! sed \
        -e "s#{{CLAUDE_DIR}}#${claude_dir_escaped}#g" \
        -e "s#{{CODEX_DIR}}#${codex_dir_escaped}#g" \
        "${source_file}" > "${rendered_file}"; then
        log_error "failed to render template: ${source_file}"
        exit "${EXIT_WRITE_FAILED}"
    fi

    install_file "${rendered_file}" "${target}"
}

# Succeed if two paths resolve to the same physical directory.
is_same_directory() {
    local first_path="$1"
    local second_path="$2"
    local first_resolved
    local second_resolved

    first_resolved="$(cd "${first_path}" 2>/dev/null && pwd -P)" || return 1
    second_resolved="$(cd "${second_path}" 2>/dev/null && pwd -P)" || return 1
    [[ "${first_resolved}" == "${second_resolved}" ]]
}

# Point the Claude skill at the Codex skill so both tools read the same file.
install_skill_link() {
    local name="$1"
    local link_path="${CLAUDE_DIR}/skills/${name}"
    local link_target="${CODEX_DIR}/skills/${name}"

    if [[ -L "${link_path}" ]] && is_same_directory "${link_path}" "${link_target}"; then
        log_info "unchanged: ${link_path}"
        return
    fi

    if ! make_room_for "${link_path}"; then
        return
    fi

    run_write "create directory ${CLAUDE_DIR}/skills" mkdir -p "${CLAUDE_DIR}/skills"
    run_write "link ${link_path} -> ${link_target}" ln -s "${link_target}" "${link_path}"
}

# Install every file for one review.
install_review() {
    local name="$1"

    install_file "${SCRIPT_DIR}/skills/${name}/SKILL.md" \
        "${CODEX_DIR}/skills/${name}/SKILL.md"
    install_file "${SCRIPT_DIR}/skills/${name}/agents/openai.yaml" \
        "${CODEX_DIR}/skills/${name}/agents/openai.yaml"
    install_skill_link "${name}"
    install_template "${SCRIPT_DIR}/agents/claude/${name}.md" \
        "${CLAUDE_DIR}/agents/${name}.md"
    install_template "${SCRIPT_DIR}/agents/codex/${name}.toml" \
        "${CODEX_DIR}/agents/${name}.toml"
}

main() {
    local name

    parse_args "$@"
    validate_sources

    render_dir="$(mktemp -d)" || {
        log_error "failed to create temporary directory"
        exit "${EXIT_WRITE_FAILED}"
    }
    trap cleanup EXIT

    log_info "Claude dir: ${CLAUDE_DIR}"
    log_info "Codex dir:  ${CODEX_DIR}"
    if [[ "${is_dry_run}" == true ]]; then
        log_info "dry run: nothing will be written"
    fi

    for name in "${REVIEW_NAMES[@]}"; do
        install_review "${name}"
    done

    if [[ "${conflict_count}" -gt 0 ]]; then
        log_warn "${conflict_count} existing item(s) skipped; rerun with --force to replace them"
        exit "${EXIT_CONFLICTS}"
    fi
    log_info "done"
}

main "$@"
