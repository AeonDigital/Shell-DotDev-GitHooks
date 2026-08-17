#!/usr/bin/env bash

# shell_pre_commit_package_export_build — Master orchestrator that iterates over
# the registered packages and triggers their individual single-file distribution
# compilation.
# 
# Description:
# - Scans the 'EXPORT_PACKAGE_REGISTER' indexed array to discover all intended packages.
# - Dynamically normalizes each package token to match Bash variable naming constraints
#   (converting to uppercase and translating hyphens to underscores).
# - Resolves the corresponding target associative configuration array using a nominal
#   reference (nameref) and dispatches the metadata to the core compilation engine.
# 
# Arguments:
# - None. (Relies on the global 'EXPORT_PACKAGE_REGISTER' array and dynamically mapped
#   global associative arrays).
# 
# Returns:
# - Sequentially triggers '_shell_pre_commit_package_build' for each registered package.
#   Aborts the execution chain immediately if any package compilation fails.
# 
# Return Codes:
# - 0: On successful compilation, export, and staging of all registered packages.
# - 1: If any individual package build pipeline fails or encounters runtime errors.
shell_pre_commit_package_export_build() {
  local package_token=""
  local assoc_name=""
  local build_status=""

  for package_token in "${EXPORT_PACKAGE_REGISTER[@]}"; do
    assoc_name="${package_token^^}"
    assoc_name="EXPORT_PACKAGE_${assoc_name//-/_}"

    # Verify if the dynamically generated associative array variable exists before
    # attempting to declare a nameref against it.
    if ! declare -p "${assoc_name}" &>/dev/null; then
      echo "[ERR] :: Assoc array '${assoc_name}' not exists!"
      echo "         Set it as the configuration for the respective package "
      echo "         or remove it from the 'EXPORT_PACKAGE_REGISTER' registry"
      return 1
    fi

    local -n current_pkg="${assoc_name}"
    _shell_pre_commit_package_build \
      "${current_pkg["project_url"]}" \
      "${current_pkg["project_name"]}" \
      "${current_pkg["project_license_type"]}" \
      "${current_pkg["project_license_url"]}" \
      "${current_pkg["project_root_path"]}" \
      "${current_pkg["source_dir_path"]}" \
      "${current_pkg["assets_dir_path"]}" \
      "${current_pkg["export_file_path"]}" \
      "${current_pkg["use_autoexec"]}"

    build_status=$?
    unset -n current_pkg

    if [ ${build_status} -ne 0 ]; then
      return 1
    fi
  done

  return 0
}


# _shell_pre_commit_package_build — Wrapper that orchestrates the single-file distribution
# build and automatically stages it.
# 
# Description:
# - Validates the availability of the upstream packaging compilation system tool.
# - Renders structured build metadata diagnostics and deployment configurations to
#   stdout.
# - Invokes the underlying compilation binary tool to aggregate and unify modular
#   codebase structures.
# - Automatically injects and stages the resulting standalone package into the current
#   Git index.
# 
# Arguments:
# - project_url:          The main repository or project home URL.
# - project_name:         The name of the project.
# - project_license_type: The short name of the license (e.g., MIT, Apache-2.0).
# - project_license_url:  The relative path to the license file from the project
#   URL.
# - project_root_path:    The absolute path to the project's root directory.
# - source_dir_path:      Optional. The relative path to the source scripts.
# - assets_dir_path:      Optional. The relative path to the assets scripts.
# - export_file_path:     Optional. The path where the destination file will be written.
#   If empty, falls back to a snake_case version of 'project_name'_package.sh.
# - use_autoexec:         Optional. The relative path to the auto-execution rules
#   script.
# 
# Returns:
# - Renders compilation metadata and statuses to stdout while mutating the local
#   git staging tree.
# 
# Return Codes:
# - 0: On successful package compilation, export, and 'git add' staging.
# - 1: If the compilation tool is missing, fails, or if Git cannot stage the final
#   package file.
_shell_pre_commit_package_build() {
  local project_url="${1}"
  local project_name="${2}"
  local project_license_type="${3}"
  local project_license_url="${4}"
  local project_root_path="${5}"
  local source_dir_path="${6}"
  local assets_dir_path="${7}"
  local export_file_path="${8}"
  local use_autoexec="${9}"

  local sh="${XDG_BIN_HOME:-$HOME/.local/bin}/shell_mngm_package/package_export.sh"
  if [ ! -f "${sh}" ]; then
    echo "[ERR] :: Packaging compilation tool not found in:"
    echo "         '${sh}'"
    return 1
  fi

  if [ "${export_file_path}" = "" ]; then
    export_file_path="${project_name,,}_package.sh"
    export_file_path="${export_file_path//-/_}"
  fi


  local cur_date=$(date +"%Y-%m-%d")
  echo "================================================================================"
  echo "BUILD SINGLE-FILE DISTRIBUTION ${export_file_path}"
  echo "                         under ${project_license_type} LICENSE"
  echo "                            in ${cur_date}"
  echo ""
  echo "      REPO URL : ${project_url}"
  echo "  LOCAL SOURCE : ${source_dir_path}"
  if [ -n "${assets_dir_path}" ]; then
    echo "   WITH ASSETS : ${assets_dir_path}"
  fi
  echo ""


  "${sh}" \
    "${project_url}" \
    "${project_name}" \
    "${project_license_type}" \
    "${project_license_url}" \
    "${project_root_path}" \
    "${source_dir_path}" \
    "${assets_dir_path}" \
    "${export_file_path}" \
    "${use_autoexec}"

  if [ $? -ne 0 ]; then
    echo "[ERR] :: Build package unexpectedly failed!"
    return 1
  fi

  # Explicitly using absolute path routing to protect staging across nested trees
  git add "${project_root_path}/${export_file_path}"
  if [ $? -ne 0 ]; then
    echo "[ERR] :: It was not possible to add the new package to the commit!"
    return 1
  fi

  return 0
}
