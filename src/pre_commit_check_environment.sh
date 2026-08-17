#!/usr/bin/env bash

# shell_pre_commit_check_environment — Top-level orchestrator validating structural,
# operational, and architectural environment compliance before hook pipeline engagement.
# 
# Description:
# - Sequences the initialization subroutines required to secure the hook framework
#   lifecycle.
# - Validates physical presence and sources external project-level environment setup
#   files.
# - Ensures global registry variable configurations match mandatory schema contracts.
# - Scans and registers dynamic sub-component functions into the active operational
#   subshell.
# 
# Arguments:
# - None. (Delegates discrete execution contexts to specialized internal subroutines).
# 
# Returns:
# - Structured execution progression state logs mapped to stdout.
# 
# Return Codes:
# - 0: On flawless environmental verification (all required conditions and configurations
#   met).
# - 1: If filesystem assets are missing, variables are undefined, or internal components
#   fail to load.
shell_pre_commit_check_environment() {
  echo "================================================================================"
  echo "[RUN] CHECK ENVIRONMENT"

  _shell_pre_commit_check_environment_config_files
  if [ $? -ne 0 ]; then
    return 1
  fi

  _shell_pre_commit_check_environment_config_variables
  if [ $? -ne 0 ]; then
    return 1
  fi

  _shell_pre_commit_check_environment_load_scripts
  if [ $? -ne 0 ]; then
    return 1
  fi

  echo "[OKK] moving on ..."
  echo ""
  return 0
}


# _shell_pre_commit_check_environment_config_files — Asserts structural availability
# and sources the foundational pre-commit user configuration files.
# 
# Description:
# - Evaluates hardcoded target file system path arrays to enforce core asset compliance.
# - Sequentially triggers native shell ingestion (.) to hydrate the environment state.
# - Short-circuits the pipeline with a fatal diagnostics error block if any configuration
#   target is missing.
# 
# Return Codes:
# - 0: All targeted configuration scripts discovered and sourced successfully.
# - 1: A critical configuration file target is physically missing from the workspace.
_shell_pre_commit_check_environment_config_files() {
  local -a required_scripts=(
    "${GIT_HOOK_CONFIG_PATH}/pre-commit.sh"
    "${GIT_HOOK_CONFIG_PATH}/pre-commit-export-package.sh"
    "${GIT_HOOK_CONFIG_PATH}/pre-commit-import-package.sh"
  )

  # Asserts physical presence of the required script files
  local file=""
  for file in "${required_scripts[@]}"; do
    if [ ! -f "${file}" ]; then
      echo "[FATAL_ERR] ACTION INTERRUPTED"
      echo "            Configuration file '${file}' not found"
      echo ""
      return 1
    fi

    . "${file}"
  done

  return 0
}


# _shell_pre_commit_check_environment_config_variables — Inspects and ensures framework
# architectural variables comply with mandatory declaration policies.
# 
# Description:
# - Iterates dynamically across the 'GIT_HOOK_GLOBAL_VAR_REGISTER' schema collection.
# - Employs variable indirection parsing (!var_name) to trap unassigned or missing
#   setups.
# - Collects anomalies into transient arrays to render comprehensive multi-line breakdown
#   reports.
# 
# Return Codes:
# - 0: All registered global control switches are assigned and stable within the
#   environment.
# - 1: One or more architectural variables are missing or unassigned, breaking framework
#   compliance.
_shell_pre_commit_check_environment_config_variables() {
  local var_name=""
  local -a array_err=()

  # Iterates dynamically using variable indirection (!) to discover unassigned setups
  for var_name in "${GIT_HOOK_GLOBAL_VAR_REGISTER[@]}"; do
    if ! declare -p "${var_name}" &>/dev/null; then
      array_err+=("[ x ] Config var '${var_name}' not defined.")
    fi
  done

  # Halts workflow execution if architecture configuration compliance issues are
  # triggered
  if [ "${#array_err[@]}" -gt "0" ]; then
    echo "[FATAL_ERR] LOST CONFIGURATION"
    echo ""

    local errmsg=""
    for errmsg in "${array_err[@]}"; do
      echo "${errmsg}"
    done
    echo "      Action interrupted!"
    echo ""

    return 1
  fi

  return 0
}


# _shell_pre_commit_check_environment_load_scripts — Discovers, sorts, and digests
# internal shell modular components to hydrate framework functionality.
# 
# Description:
# - Pinpoints the underlying framework source scripts storage path.
# - Runs a null-delimited, sorted find operation to loop through source assets deterministically.
# - Sources individual features into memory, allowing native syntax errors to output
#   clearly, while collecting tracking references to build precise execution failure
#   reports.
# 
# Return Codes:
# - 0: All internal modular sub-scripts sourced and bound to the subshell without
#   faults.
# - 1: Source directories are missing or internal sub-scripts fail to be parsed/ingested.
_shell_pre_commit_check_environment_load_scripts() {
  local target_scripts="${GIT_HOOK_PROJECT_ROOT_PATH}/${GIT_HOOK_TOOLS_PATH}/src"

  if [ ! -d "${target_scripts}" ]; then
    echo "[FATAL_ERR] PRE-CONFIG SCRIPTS NOT FOUND."
    echo "            lost directory '${target_scripts}'"
    echo ""
    return 1
  fi

  local hook_scripts=""
  local -a array_load_err=()

  # Sours every script inside tools and logs errors into a transient collection.
  while IFS= read -r -d '' hook_scripts; do
    if ! . "${hook_scripts}" 2>/dev/null; then
      array_load_err+=("      - ${hook_scripts}")
    fi
  done < <(find "${target_scripts}" -type f -name "*.sh" -print0 2>/dev/null | LC_ALL=C sort -z)

  # Check if internal script crashes or a pipeline loop error occurred
  if [ "${#array_load_err[@]}" -gt "0" ]; then
    echo "[FATAL_ERR] PRE-CONFIG COMPONENT INGESTION PIPELINE FAILED"
    echo ""
    echo "[ x ] The following scripts failed to load:"

    local load_errmsg=""
    for load_errmsg in "${array_load_err[@]}"; do
      echo "${load_errmsg}"
    done

    echo ""
    echo "      Action interrupted!"
    echo ""
    return 1
  fi

  return 0
}
