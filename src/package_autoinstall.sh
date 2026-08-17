#!/usr/bin/env bash

# shell_pre_commit_package_export_autoinstall — Master orchestrator that iterates
# over the registered packages and triggers their local deployment into the developer's
# execution path.
# 
# Description:
# - Scans the 'EXPORT_PACKAGE_REGISTER' indexed array to discover all target packages.
# - Dynamically normalizes each package token to resolve its corresponding associative
#   configuration array via a nominal reference (nameref).
# - Dispatches the structural paths and metadata required by the underlying installation
#   binary to provision the local binary directory.
# 
# Arguments:
# - None. (Relies on the global 'EXPORT_PACKAGE_REGISTER' array and dynamically mapped
#   global associative arrays).
# 
# Returns:
# - Sequentially triggers '_shell_pre_commit_package_autoinstall' for each registered
#   package. Aborts the deployment pipeline immediately if any installation subroutine
#   fails.
# 
# Return Codes:
# - 0: On successful local installation and deployment of all registered packages.
# - 1: If any individual package installation encounters runtime deployment errors.
shell_pre_commit_package_export_autoinstall() {
  local package_token=""
  local assoc_name=""
  local install_status=""

  for package_token in "${EXPORT_PACKAGE_REGISTER[@]}"; do
    assoc_name="${package_token^^}"
    assoc_name="EXPORT_PACKAGE_${assoc_name//-/_}"

    # Verify if the dynamically generated associative array variable exists before
    # attempting to declare a nameref against it.
    if ! declare -p "${assoc_name}" &>/dev/null; then
      echo "[ERR] :: Assoc array '${assoc_name}' not exists for auto-installation!"
      return 1
    fi

    local -n current_pkg="${assoc_name}"

    # Trigger the local deployment and capture the return status immediately. Maps
    # internal associative array keys to the target core function parameters.
    _shell_pre_commit_package_autoinstall \
      "${current_pkg["project_root_path"]}" \
      "${current_pkg["project_name"]}" \
      "${current_pkg["export_file_path"]}"

    install_status=$?

    # Explicitly break the nameref reference before scope changes or next iteration.
    unset -n current_pkg

    if [ ${install_status} -ne 0 ]; then
      return 1
    fi
  done

  return 0
}


# _shell_pre_commit_package_autoinstall — Installs the newly built single-file distribution
# into the developer's local environment.
# 
# Description:
# - Normalizes the target project names to adhere to standard system naming schemas.
# - Verifies the structural existence of the source compilation bundle generated
#   in prior phases.
# - Ensures the provisioned user-local binary container path directory layout is
#   ready ($HOME/.local/bin).
# - Copies the generated package directly into the local execution path, granting
#   standalone usage.
# 
# Arguments:
# - project_root_path: The absolute path to the project's root directory where the
#   package was built.
# - project_name:      The clean name of the project (used to create the local container
#   directory).
# - package_filename:  Optional. The name of the package file to be copied. If empty,
#   falls back to a snake_case version of 'project_name'_package.sh.
# 
# Returns:
# - Renders installation paths and provisioning completion logs to stdout.
# 
# Return Codes:
# - 0: On successful package deployment and local environment installation.
# - 1: If the origin package file cannot be found, or if local directory creation
#   fails.
_shell_pre_commit_package_autoinstall() {
  local project_root_path="${1}"
  local project_name="${2}"
  local package_filename="${3}"

  local package_pathname="${project_name,,}"
  package_pathname="${package_pathname//-/_}"

  if [ "${package_filename}" = "" ]; then
    package_filename="${project_name,,}_package.sh"
    package_filename="${package_filename//-/_}"
  fi

  local origin_package_file_path="${project_root_path}/${package_filename}"

  # Build target paths safely (Using package_pathname as defined in shell_install
  # original logic)
  local local_package_dir_path="${XDG_BIN_HOME:-$HOME/.local/bin}/${package_pathname}"
  local local_package_file_path="${local_package_dir_path}/${package_filename}"



  echo ""
  echo "================================================================================"
  echo "AUTO-INSTALL DISTRIBUTION "
  echo ""
  echo "     Project Root Path : ${project_root_path}"
  echo "    Package Build File : ${origin_package_file_path/${project_root_path}\//}"
  echo "          Install path : ${local_package_file_path}"
  echo ""


  if [ ! -f "${origin_package_file_path}" ]; then
    echo "[ x ] :: Origin package file not found!"
    echo "[ERR] :: AUTO-INSTALL FAIL"
    return 1
  fi


  # Ensure the container directory exists
  mkdir -p "${local_package_dir_path}"
  if [ $? -ne 0 ]; then
    echo "[ERR] :: Cannot create '${local_package_dir_path}' directory"
    echo "         Check permissions and try again."
    return 1
  fi

  cp "${origin_package_file_path}" "${local_package_file_path}"
  echo "[ v ] :: Package '${project_name} -> ${package_filename}' was successfully installed in"
  echo "         '${local_package_file_path}'"
  echo ""

  return 0
}
