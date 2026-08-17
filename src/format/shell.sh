#!/usr/bin/env bash


# shell_pre_commit_format_shell — Scans target script directories to discover shell
# source files and applies core structural formatting compliance.
# 
# Description:
# - Systematically scans source and asset directories to isolate matching '*.sh'
#   targets.
# - Enforces a deterministic null-delimited alphabetical sorting chain to preserve
#   consistent execution layouts across environments.
# - Aggregates all validated script components and proxies the compilation array
#   context directly to the backend formatting infrastructure.
# 
# Arguments:
# - project_root_path: Absolute base path directing operations from the framework
#   root level.
# - project_name:      System deployment label identifier used to extract internal
#   utilities.
# - package_filename:  Optional script execution package naming override.
# - source_dir_path:   Relative tracking directory indicating core script structures.
# - assets_dir_path:   Optional secondary folder grouping supplementary shell templates.
# 
# Returns:
# - Dispatches the discovered shell file collection reference to the backend formatting
#   engine.
shell_pre_commit_format_shell() {
  local project_root_path="${1}"
  local project_name="${2}"
  local package_filename="${3}"
  local source_dir_path="${4}"
  local assets_dir_path="${5:-}"

  local file=""
  local has_files="0"
  local -a array_formatter_tgt_files=()

  # Resolves targets using unified absolute directory paths to protect loop stability
  local abs_source_path="${project_root_path}/${source_dir_path%/}"
  while IFS= read -r -d '' file; do
    has_files="1"
    array_formatter_tgt_files+=("${file}")
  done < <(find "${abs_source_path}" -type f -name "*.sh" -print0 2>/dev/null | LC_ALL=C sort -z)


  if [ -n "${assets_dir_path}" ]; then
    has_files="0"
    local abs_assets_path="${project_root_path}/${assets_dir_path%/}"
    while IFS= read -r -d '' file; do
      has_files="1"
      array_formatter_tgt_files+=("${file}")
    done < <(find "${abs_assets_path}" -type f -name "*.sh" -print0 2>/dev/null | LC_ALL=C sort -z)
  fi

  shell_pre_commit_generic_format_engine \
    "${project_root_path}" "${project_name}" "${package_filename}" "sh" \
    "array_formatter_tgt_files" "${source_dir_path}" "${assets_dir_path}"

  return $?
}
