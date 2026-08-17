#!/usr/bin/env bash

# shell_pre_commit_generic_format_engine — Execution bridge that iterates over pre-resolved
# targets to apply localized package formatting binaries.
# 
# Description:
# - Discovers and maps the specialized executable binary from the XDG/home local
#   path.
# - Validates target availability using an incoming array reference (nameref).
# - Dispatches file-by-file formatting pipelines, tracks individual run statistics,
#   and delegates post-execution workspace checking to the Git compliance validator.
# 
# Arguments:
# - project_root_path:  The absolute path reference tracking the system workspace
#   root.
# - project_name:       Clean canonical system name used to establish local path
#   resolutions.
# - package_filename:   Optional binary wrapper file mapping. Defaults to standard
#   templates if passed empty.
# - extension_label:    Text visual string token mapping the target language (e.g.,
#   'sh', 'md').
# - target_files_ref:   Name reference (nameref) linking to an indexed array containing
#   the absolute/resolved file pathways.
# - Array of paths:     Remaining parameters defining the Git validation tracking
#   scope ($@).
# 
# Returns:
# - Renders real-time execution outputs, diagnostics, and final formatting run statistics.
# 
# Return Codes:
# - 0: On successful execution where no file modifications or pipeline crashes are
#   left.
# - 1: If binary validation checkpoints fail, or if applied changes trigger commit
#   blocks.
shell_pre_commit_generic_format_engine() {
  local project_root_path="${1}"
  local project_name="${2}"
  local package_filename="${3}"
  local extension_label="${4}"
  local -n target_files_ref="${5}"
  shift 5
  local git_diff_paths=("$@")


  # Internal variables parsing standard snake_case naming constraints
  local package_pathname="${project_name,,}"
  package_pathname="${package_pathname//-/_}"

  if [ "${package_filename}" = "" ]; then
    package_filename="${project_name,,}_package.sh"
    package_filename="${package_filename//-/_}"
  fi

  local local_package_dir_path="${XDG_BIN_HOME:-$HOME/.local/bin}/${package_pathname}"
  local sh="${local_package_dir_path}/${package_filename}"

  echo ""
  echo "================================================================================"
  echo "STARTING FORMAT FILES .${extension_label}"
  echo "   using '${sh}'"
  echo ""

  if [ ! -f "${sh}" ]; then
    echo "[ERR] :: Formatter not found in"
    echo "         '${sh}'"
    return 1
  fi

  if [ "${#target_files_ref[@]}" -eq 0 ]; then
    echo "[ ! ] No .${extension_label} target files provided for processing."
    echo "[END] Skipping .${extension_label} formatting step!"
    return 0
  fi

  echo "[ ! ] :: Found ${#target_files_ref[@]} target .${extension_label} files"
  echo "         in '${project_root_path}'"
  echo ""

  local target_file_path=""
  local mark=""
  local formatting_fail="0"
  local formatting_success="0"

  for target_file_path in "${target_files_ref[@]}"; do
    mark="v"

    # Executes the external formatting script wrapper inside double quotes
    "${sh}" "${target_file_path}"
    if [ $? -ne 0 ]; then
      mark="x"
      ((formatting_fail++))
    else
      ((formatting_success++))
    fi

    echo "[ ${mark} ] - ${target_file_path/${project_root_path}\//}"
  done

  echo ""
  echo "[ ! ] :: Formatting execution report:"
  echo "         Successful runs : ${formatting_success}"
  echo "         Failed runs     : ${formatting_fail}"

  if [ "${formatting_fail}" -gt 0 ]; then
    echo "[ERR] :: Formatter process encountered internal execution errors."
    return 1
  fi

  # Delegates working directory compliance checking to the detached validator function
  shell_pre_commit_check_git_compliance \
    ${project_root_path} \
    "Code styling enhancements applied successfully by the ${extension_label^^} formatter" \
    "${git_diff_paths[@]}"

  return $?
}
