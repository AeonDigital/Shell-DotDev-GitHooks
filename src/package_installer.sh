#!/usr/bin/env bash

# shell_pre_commit_package_installer — Downloads and installs a modular shell script
# package from a remote repository target if it is missing from the local user execution
# ecosystem.
# 
# Description:
# - Normalizes project naming strings to match operating system directory path patterns.
# - Evaluates local binary cache availability and processes explicit auto-update
#   eviction flags.
# - Checks global unattended automation flags ('GIT_HOOK_ACTIVE_PACKAGE_INSTALLER_NON_INTERACTIVE')
#   to bypass or enforce interactive human validation gates before data transfer
#   execution.
# - Bypasses Git hook stdin hijacking by targeting the controlling terminal device
#   with a safe non-blocking 10-second timeout fall-through fallback mechanism.
# - Executes downstream curl transfer streams, monitors HTTP transport compliance,
#   provisions container scopes, and configures standalone execution permissions
#   (+x).
# 
# Arguments:
# - upstream_base_url:  The remote baseline repository host or organization endpoint
#   URL.
# - package_name:       The clean name of the project repository (used to compile
#   targeting urls).
# - package_filename:   The targeted delivery name for the pulled standalone executable
#   asset.
# - package_autoupdate: Optional. Force eviction string flag ("true") to trigger
#   old asset cleanup.
# - interface_header:   Optional. Custom diagnostic message rendered during initial
#   standard logs.
# 
# Returns:
# - Standard diagnostic progression outputs to stdout and live terminal interactive
#   validation prompts.
# 
# Return Codes:
# - 0: Asset provisioned successfully, active auto-update completed, or valid cache
#   found.
# - 1: Non-interactive environment bottleneck, cache cleanup failures, download errors,
#   or user aborts.
shell_pre_commit_package_installer() {
  local upstream_base_url="${1}"
  local package_name="${2}"
  local package_filename="${3}"
  local package_autoupdate="${4}"
  local interface_header="${5}"

  local package_pathname="${package_name,,}"
  package_pathname="${package_pathname//-/_}"

  # Build target paths safely (Using package_pathname as defined in core lifecycle
  # logic)
  local local_package_dir_path="${XDG_BIN_HOME:-$HOME/.local/bin}/${package_pathname}"
  local local_package_file_path="${local_package_dir_path}/${package_filename}"

  echo "================================================================================"
  if [ -n "${interface_header}" ]; then
    echo "${interface_header}"
    echo ""
  fi
  echo "[ ! ] :: Check for package '${package_name} -> ${package_filename}'"

  # Processes explicit eviction / cache invalidation routines
  if [ "${package_autoupdate}" = "true" ] && [ -f "${local_package_file_path}" ]; then
    rm "${local_package_file_path}"
    if [ $? -ne 0 ]; then
      echo "[ERR] :: Cannot remove old '${package_name} -> ${package_filename}' from"
      echo "         '${local_package_file_path}'"
      echo "         Check file system permissions and try again."
      echo ""
      echo "         Auto Update FAIL!"
      return 1
    fi
  fi

  # Cache Hit: Skip downstream transport if valid asset exists on disk
  if [ -f "${local_package_file_path}" ]; then
    echo "[ v ] :: Found in '${local_package_file_path}'"
    echo ""
    echo ""
    return 0
  fi

  local target_url="${upstream_base_url%/}/${package_name}/refs/heads/main/${package_filename}"
  local execute_download="false"

  echo "[ ! ] :: NOT FOUND"
  echo "         Trying download from:"
  echo "         '${target_url}'"
  echo "         to:"
  echo "         '${local_package_file_path}'"
  echo ""

  # Evaluates whether the system is allowed to perform a silent auto-installation
  if [ "${GIT_HOOK_ACTIVE_PACKAGE_INSTALLER_NON_INTERACTIVE}" = "true" ]; then
    echo "[ ! ] :: Unattended auto-approve mode active. Proceeding with installation..."
    execute_download="true"
  else
    # Safe guard: Abort early if running in a headless environment without a valid
    # controlling TTY
    if [ ! -r /dev/tty ] || [ ! -w /dev/tty ]; then
      echo "[ERR] :: Non-interactive headless terminal environment detected and auto-approve is disabled."
      echo "         Cannot open a user input prompt without a valid controlling terminal device (/dev/tty)."
      echo "         Please configure 'GIT_HOOK_ACTIVE_PACKAGE_INSTALLER_NON_INTERACTIVE=true' or run"
      echo "         this script manually in an interactive shell to provision the tool."
      return 1
    fi

    local user_entry=""
    echo "[ ? ] :: Do you allow this download? (y/n) [Auto-aborting in 10s]"

    # Read from /dev/tty with a 10-second timeout to handle Git hook pipeline redirection
    if read -t 10 -p "[ > ] :: " -r user_entry < /dev/tty; then
      user_entry=${user_entry,,}
      if [ "${user_entry}" = "y" ]; then
        execute_download="true"
      fi
    else
      echo ""
      echo "[ ! ] :: Timeout reached with no response. Defaulting to deny."
    fi
  fi

  if [ "${execute_download}" != "true" ]; then
    echo "[END] :: Pre-commit aborted by user choice or inactivity."
    return 1
  fi

  # Ensure the destination container folder layout is ready
  mkdir -p "${local_package_dir_path}"
  if [ $? -ne 0 ]; then
    echo "[ERR] :: Cannot create '${local_package_dir_path}' directory structure."
    echo "         Check file permissions and try again."
    return 1
  fi

  # Execute network stream ingestion tracking error contexts inline
  local curl_output
  curl_output=$(curl -sSL -S -w "%{http_code}" "${target_url}" -o "${local_package_file_path}" 2>&1)
  local curl_status=$?

  if [ ${curl_status} -ne 0 ]; then
    echo "[ERR] :: Transmit stream failed."
    echo "         Target : '${target_url}'"
    echo "         Network Diagnostics: ${curl_output%000}"
    rm -f "${local_package_file_path}"
    return 1
  fi

  # Extracts the HTTP Status Code using safe fallback parsing metrics
  local http_code="${curl_output: -3}"
  if [[ ! "${http_code}" =~ ^2[0-9]{2}$ ]]; then
    echo "[ERR] :: Upstream package retrieval failed."
    echo "         Target : '${target_url}'"
    echo "         HTTP Status Code: ${http_code}"
    rm -f "${local_package_file_path}"
    return 1
  fi

  echo "[ v ] :: Package '${package_name} -> ${package_filename}' successfully downloaded to"
  echo "         '${local_package_file_path}'"

  # Provision executable flags to integrate the script into local execution workflows
  chmod +x "${local_package_file_path}"
  if [ $? -ne 0 ]; then
    echo "[ x ] :: Could not grant execution (+x) permission for the downloaded package."
    echo "         Check user/group permissions and execute manually:"
    echo "         > chmod +x '${local_package_file_path}'"
    echo "[END] :: Installation completed with partial operational state."
    return 1
  fi

  return 0
}
