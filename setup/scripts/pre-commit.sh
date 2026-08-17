#!/usr/bin/env bash

# Enforces strict variable evaluation to prevent execution with unbound contexts
set -u



# ==============================================================================
# git/pre-commit - Main Lifecycle Hook Orchestrator & Quality Gatekeeper
# ==============================================================================

if [ -z "${GIT_HOOK_TOOLS_PATH+x}" ]; then
  declare -gr GIT_HOOK_TOOLS_PATH=".dev/tools/githooks"
fi
if [ -z "${GIT_HOOK_CONFIG_PATH+x}" ]; then
  declare -gr GIT_HOOK_CONFIG_PATH=".dev/config/githooks"
fi


# Fast intercept: Secure the baseline initialization script environment path
if  [ ! -f "${GIT_HOOK_TOOLS_PATH}/src/pre_commit_check_location.sh" ] || 
    [ ! -f "${GIT_HOOK_TOOLS_PATH}/src/pre_commit_check_environment.sh" ]; then
  echo "[FATAL_ERR] ACTION INTERRUPTED"
  echo "            Could not find the startup scripts!!"
  echo ""
  echo "          > Make sure you are running from the project's root directory."
  echo ""
  echo "          > Check if the scripts listed below exist:"
  echo "            - ${GIT_HOOK_TOOLS_PATH}/src/pre_commit_check_location.sh"
  echo "            - ${GIT_HOOK_TOOLS_PATH}/src/pre_commit_check_environment.sh"
  echo ""
  exit 1
fi

# Ingest baseline functions and early initialization routers
. "${GIT_HOOK_TOOLS_PATH}/src/pre_commit_check_location.sh"
. "${GIT_HOOK_TOOLS_PATH}/src/pre_commit_check_environment.sh"

# Run defensive baseline space and environment diagnostic barriers
shell_pre_commit_check_location || exit 1
shell_pre_commit_check_environment || exit 1

# Execute optional early user hooks and project diagnostics telemetry
shell_pre_commit_start_header


# Gatekeeper: Graciouly intercept and exit if the architecture toggle is disabled
if [ "${GIT_HOOK_ACTIVE_PRE_COMMIT}" = "false" ]; then
  shell_pre_commit_end_header
  exit 0
fi



# ==============================================================================
# STEP 1: UPSTREAM EXTERNAL DEPENDENCIES PROVISIONING PIPELINE
# ==============================================================================
# Dynamically resolves and pulls all external dependencies registered by the dev
shell_pre_commit_package_import || exit 1



# ==============================================================================
# STEP 2: MULTI-PACKAGE DISTRIBUTION COMPILATION & TARGET INSTALLATION
# ==============================================================================
if [ "${GIT_HOOK_ACTIVE_PACKAGE_BUILDER}" = "true" ]; then
  shell_pre_commit_package_export_build || exit 1

  if [ "${GIT_HOOK_ACTIVE_PACKAGE_BUILDER_AUTOINSTALL}" = "true" ]; then
    shell_pre_commit_package_export_autoinstall || exit 1
  fi
fi



# ==============================================================================
# STEP 3: CODEBASE ESTHETIC SPECIFICATION LINTERS & STYLERS
# ==============================================================================
if [ "$GIT_HOOK_ACTIVE_MD_FORMATTER" = "true" ]; then
  shell_pre_commit_format_markdown \
    "${GIT_HOOK_PROJECT_ROOT_PATH}" \
    "MD-ReadI" \
    "package.sh" || exit 1
fi

if [ "$GIT_HOOK_ACTIVE_SH_FORMATTER" = "true" ]; then
  shell_pre_commit_format_shell \
    "${GIT_HOOK_PROJECT_ROOT_PATH}" \
    "Shell-Formatter" \
    "package.sh" \
    "src" || exit 1
fi



# ==============================================================================
# STEP 4: SUCCESSFUL LIFECYCLE CLOSURE & HANDOVER
# ==============================================================================
shell_pre_commit_end_header
exit 0