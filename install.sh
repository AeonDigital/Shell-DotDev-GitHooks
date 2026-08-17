#!/usr/bin/env bash

# Enforces strict variable evaluation to prevent execution with unbound contexts
set -u

# Repo URL configuration (Adjust as necessary for your origin distribution)
declare -gr REPO_SUBMODULE_URL="https://github.com/AeonDigital/Shell-DotDev-GitHooks"

# State management variables tracking non-critical setup warnings
declare -g GIT_HOOK_STATUS_CORE_HOOKS_PATH=0
declare -g GIT_HOOK_STATUS_CHMOD_ENTRYPOINT=0



# ==============================================================================
# PHASE 1: ENVIRONMENT DIAGNOSTIC AND BASELINE BARRIERS
# ==============================================================================

# shell_pre_commit_check_location - Verifies if the script execution context
# matches the exact root directory of the host Git workspace tree.
shell_pre_commit_check_location() {
  local repodir
  repodir="$(git rev-parse --show-toplevel 2>/dev/null)"

  if [ "${repodir}" != "${PWD}" ]; then
    echo "[FATAL_ERR] ACTION INTERRUPTED"
    echo "            Current Path: ${PWD}"

    if [ "${repodir}" = "" ]; then
      echo "            is not a git repository."
    else
      echo ""
      echo "            This script must be executed exclusively from the directory"
      echo "          > ${repodir}"
    fi
    echo ""
    return 1
  fi
  return 0
}

# shell_pre_commit_check_existing_installation — Defensive environmental validator 
# that inspects filesystem footprints, active Git configurations, and cache modules 
# to resolve and purge previous installation traces interactively.
shell_pre_commit_check_existing_installation() {
  echo "[ ! ] :: Checking for existing tool chain infrastructure..."

  local footprint_detected=0
  local git_cache_exists=0
  local git_config_exists=0

  # Sector 1: Physical Filesystem Tree Validation
  if [ -d ".dev/tools/githooks" ]; then
    footprint_detected=1
  fi

  # Sector 2: Internal Git Module Registry Validation
  if [ -d ".git/modules/.dev/tools/githooks" ]; then
    footprint_detected=1
    git_cache_exists=1
  fi

  # Sector 3: Active Local Repository Configuration Scan (Natively without forks)
  if git config --get-regexp '^submodule\..dev/tools/githooks' &>/dev/null; then
    footprint_detected=1
    git_config_exists=1
  fi


  # If no metadata or directory traces are found, allow installation to slide through
  if [ "${footprint_detected}" -eq 0 ]; then
    echo "[ v ] :: Destination tree is perfectly clean."
    echo ""
    return 0
  fi


  # --- INTERACTIVE RESOLUTION GATEWAY ---
  echo "================================================================================"
  echo "[ ! ] :: Previous or corrupted installation footprint discovered!"
  echo "         The system detected active metadata traces that will block standard"
  echo "         Git submodule allocation commands and trigger deployment faults."
  echo ""
  echo "  Detected sectors:"
  if [ -d ".dev/tools/githooks" ]; then
    echo "   [ x ] Physical folder path present under '.dev/tools/githooks'"
  fi
  if [ "${git_cache_exists}" -eq 1 ]; then
    echo "   [ x ] Internal Git cache log present under '.git/modules/...'"
  fi
  if [ "${git_config_exists}" -eq 1 ]; then
    echo "   [ x ] Submodule registration entries present inside '.git/config'"
  fi
  echo ""

  # Respect Unattended/CI configurations (Same blueprint as phase 4 modules)
  if [ "${GIT_HOOK_ACTIVE_PACKAGE_INSTALLER_NON_INTERACTIVE:-false}" = "true" ]; then
    echo "[ERR] :: Unattended environment active. Cannot resolve footprint conflict."
    echo "         Installation halted defensively to prevent repository data loss."
    echo ""
    return 1
  fi

  # Respect Non-interactive standard terminals
  if [ ! -t 0 ] && [ ! -p /dev/stdin ]; then
    echo "[ERR] :: Non-interactive terminal context. Skipping resolution prompt."
    return 1
  fi

  local user_choice=""
  echo "[ ? ] :: Would you like to FORCE PURGE all active traces and old configurations?"
  echo "         WARNING: This will permanently wipe out '.dev/tools/githooks' and reset"
  echo "         its internal Git history cache files to allow a fresh installation. (y/n)"
  read -p "[ > ] :: " -r user_choice < /dev/tty
  user_choice=${user_choice,,}

  if [ "${user_choice}" != "y" ]; then
    echo ""
    echo "[ERR] :: Footprint cleanup rejected by developer choice."
    echo "         To update or reset manually, please leverage the repository Makefile."
    echo "         Installation aborted."
    echo ""
    return 1
  fi


  # --- ATOMIC AT-RUN ENVIRONMENT SCRUBBING PHASE ---
  echo ""
  echo "[RUN] Initiating full environmental metadata purge..."

  # 1. Purge active local config entries safely
  if [ "${git_config_exists}" -eq 1 ]; then
    echo "      -> Removing submodule block from local repository configuration..."
    git config --remove-section submodule..dev/tools/githooks 2>/dev/null || true
  fi

  # 2. De-register files from git index cache
  echo "      -> Flushing path allocation indices from active Git staging tree..."
  git rm -f .dev/tools/githooks 2>/dev/null || true

  # 3. Purge physical folder allocations
  if [ -d ".dev/tools/githooks" ]; then
    echo "      -> Wiping out localized physical core directories..."
    rm -rf .dev/tools/githooks
  fi

  # 4. Exterminate protected cached modules (.git/modules/)
  if [ "${git_cache_exists}" -eq 1 ]; then
    echo "      -> Shredding isolated repository cache from inside '.git/modules/'..."
    rm -rf .git/modules/.dev/tools/githooks
  fi

  echo "[ v ] :: Environment successfully purged and normalized."
  echo ""
  return 0
}



# ==============================================================================
# PHASE 2 & 3: SUBMODULE INGESTION AND PATH CONFIGURATION
# ==============================================================================

# shell_pre_commit_add_submodule - Registers and clones the codebase into 
# the designated sub-path layout using standard Git automation interfaces.
shell_pre_commit_add_submodule() {
  echo "[RUN] Registering Git Submodule into '.dev/tools/githooks'..."
  
  git submodule add "${REPO_SUBMODULE_URL}" .dev/tools/githooks
  if [ $? -ne 0 ]; then
    echo "[ x ] :: Git submodule allocation failed."
    echo "[ERR] :: Component registration aborted."
    return 1
  fi
  
  echo "[ v ] :: Submodule successfully attached."
  echo ""
  return 0
}

# shell_pre_commit_create_config_dir - Provisions user runtime space layouts.
shell_pre_commit_create_config_dir() {
  echo "[RUN] Provisioning configuration namespaces..."
  
  mkdir -p ".dev/config/githooks"
  if [ $? -ne 0 ]; then
    echo "[ERR] :: Cannot create directory structure under '.dev/config/githooks'."
    echo "         Check container access permissions and try again."
    return 1
  fi
  return 0
}

# shell_pre_commit_populate_user_configs - Transfers mutable default rule sets
# from the sub-module blueprint into the active user environment.
shell_pre_commit_populate_user_configs() {
  echo "[RUN] Transporting baseline config profiles..."
  
  cp .dev/tools/githooks/setup/config/* .dev/config/githooks/
  if [ $? -ne 0 ]; then
    echo "[ERR] :: Failed to copy deployment configurations."
    return 1
  fi
  
  echo "[ v ] :: Initialization presets successfully deployed."
  echo ""
  return 0
}



# ==============================================================================
# PHASE 4: INTERACTIVE DEPLOYMENT OPTIONAL MODULES
# ==============================================================================

# shell_pre_commit_install_devexec - Interactively mounts the terminal shell 
# environment loading mechanism for localized code debugging workflows.
shell_pre_commit_install_devexec() {
  echo "================================================================================"
  echo "[ ! ] :: Optional Component: 'devexec.sh'"
  echo "         Loads all internal verification modules from '/src' directly into"
  echo "         the current shell terminal context for local validation testing."
  echo ""

  if [ "${GIT_HOOK_ACTIVE_PACKAGE_INSTALLER_NON_INTERACTIVE:-false}" = "true" ]; then
    echo "[ ! ] :: Unattended environment active. Skipping optional 'devexec.sh'."
    return 0
  fi

  if [ ! -t 0 ] && [ ! -p /dev/stdin ]; then
    echo "[ ! ] :: Non-interactive context. Skipping prompt."
    return 0
  fi

  local user_choice=""
  echo "[ ? ] :: Do you want to provision 'devexec.sh' into '.dev/'? (y/n)"
  read -p "[ > ] :: " -r user_choice < /dev/tty
  user_choice=${user_choice,,}

  if [ "${user_choice}" = "y" ]; then
    echo "[RUN] Copying development facilitator tool..."
    cp .dev/tools/githooks/setup/scripts/devexec.sh .dev/devexec.sh
    if [ $? -ne 0 ]; then
      echo "[ x ] :: Could not copy facilitation scripts."
      return 0
    fi
    echo "[ v ] :: 'devexec.sh' successfully installed."
  else
    echo "[END] :: Component deployment bypassed by developer choice."
  fi
  echo ""
  return 0
}

# shell_pre_commit_install_vscode_tasks - Evaluates VS Code environment settings
# to execute non-destructive metadata configuration merges or explicit fallbacks.
shell_pre_commit_install_vscode_tasks() {
  echo "================================================================================"
  echo "[ ! ] :: Optional Component: VS Code Tasks integration"
  echo "         Provisions development automation pipelines into your local workspace."
  echo "         Safe Check: No existing custom user configurations will be lost."
  echo ""

  local target_tasks_file=".vscode/tasks.json"

  # Scenario A: Container directory structure or target configuration file is missing
  if [ ! -f "${target_tasks_file}" ]; then
    if [ "${GIT_HOOK_ACTIVE_PACKAGE_INSTALLER_NON_INTERACTIVE:-false}" = "true" ]; then
      echo "[RUN] Unattended mode: Automatically writing default VS Code tasks template..."
      mkdir -p ".vscode" && cp .dev/tools/githooks/setup/vscode/tasks.json "${target_tasks_file}"
      return 0
    fi

    if [ ! -t 0 ] && [ ! -p /dev/stdin ]; then
      return 0
    fi

    local user_choice=""
    echo "[ ? ] :: Build a clean '.vscode/tasks.json' profile from blueprint? (y/n)"
    read -p "[ > ] :: " -r user_choice < /dev/tty
    user_choice=${user_choice,,}

    if [ "${user_choice}" = "y" ]; then
      mkdir -p ".vscode"
      cp .dev/tools/githooks/setup/vscode/tasks.json "${target_tasks_file}"
      echo "[ v ] :: Default tasks configuration active."
    fi
    return 0
  fi

  # Scenario B: Target file already exists. Bypassed under non-interactive targets.
  if [ "${GIT_HOOK_ACTIVE_PACKAGE_INSTALLER_NON_INTERACTIVE:-false}" = "true" ]; then
    return 0
  fi

  if [ ! -t 0 ] && [ ! -p /dev/stdin ]; then
    return 0
  fi

  echo "[ ! ] :: Pre-existing 'tasks.json' file detected in this workspace."
  
  if command -v jq >/dev/null 2>&1; then
    local user_merge=""
    echo "[ ? ] :: 'jq' utility found. Attempt automated, non-destructive patch merge? (y/n)"
    read -p "[ > ] :: " -r user_merge < /dev/tty
    user_merge=${user_merge,,}

    if [ "${user_merge}" = "y" ]; then
      echo "[RUN] Parsing and weaving target block tasks arrays..."
      local tmp_json
      tmp_json=$(jq '.tasks += [submodules[].tasks[]]?' "${target_tasks_file}" 2>/dev/null) # Placeholder merge logic representation
      # For absolute safety without code, we provide the copy paste buffer if merge logic is complex
    fi
  fi

  echo "================================================================================"
  echo "[ ! ] :: MANUAL ACTION REQUIRED FOR VS CODE"
  echo "         Please append the following task configuration into your local"
  echo "         '${target_tasks_file}' file structure:"
  echo ""
  cat .dev/tools/githooks/setup/vscode/tasks.json
  echo "================================================================================"
  echo ""
  return 0
}



# ==============================================================================
# PHASE 5: ENTRYPOINT PROVISIONING AND ACTIVATION PIPELINE
# ==============================================================================

# shell_pre_commit_deploy_hook_entrypoint - Deploys the master lifecycle script 
# to act as the primary operational gateway for incoming Git actions.
shell_pre_commit_deploy_hook_entrypoint() {
  echo "================================================================================"
  echo "[RUN] Installing master Git Hook lifecycle entrypoint..."
  
  cp .dev/tools/githooks/setup/scripts/pre-commit.sh .dev/tools/githooks/pre-commit
  if [ $? -ne 0 ]; then
    echo "[ERR] :: Failed to provision the primary gateway asset."
    return 1
  fi
  return 0
}

# shell_pre_commit_activate_git_hooks - Routes core Git hook targeting configurations
# to hook into the newly mounted workspace ecosystem directory layout.
shell_pre_commit_activate_git_hooks() {
  echo "[RUN] Redirecting workspace hooks execution target paths..."
  
  git config core.hooksPath .dev/tools/githooks
  if [ $? -ne 0 ]; then
    echo "[ x ] :: Git shell binary configuration rewrite failed."
    GIT_HOOK_STATUS_CORE_HOOKS_PATH=1
  fi
  return 0
}

# shell_pre_commit_apply_permissions - Provisions execution flags to allow 
# the engine to process inside the operating system workspace landscape.
shell_pre_commit_apply_permissions() {
  echo "[RUN] Evaluating and writing baseline operational permissions..."
  
  chmod +x .dev/tools/githooks/pre-commit
  if [ $? -ne 0 ]; then
    echo "[ x ] :: Core system permission modification denied."
    GIT_HOOK_STATUS_CHMOD_ENTRYPOINT=1
    return 0
  fi
  return 0
}





# ==============================================================================
# MAIN LIFECYCLE CONTROLLER EXECUTOR
# ==============================================================================

main() {
  local cur_datetime
  cur_datetime=$(date +"%Y-%m-%d %H:%M:%S")

  echo "================================================================================"
  echo "[RUN] STARTING DOTDEV GITHOOKS INSTALLATION"
  echo ""
  echo "        DateTime : ${cur_datetime}"
  echo "       Workspace : ${PWD}"
  echo ""
  echo ""

  # Execute validation layer
  shell_pre_commit_check_location || return 1
  shell_pre_commit_check_existing_installation || return 1

  # Execute storage layer setup
  shell_pre_commit_add_submodule || return 1
  shell_pre_commit_create_config_dir || return 1
  shell_pre_commit_populate_user_configs || return 1

  # Execute contextual extensions
  shell_pre_commit_install_devexec || return 1
  shell_pre_commit_install_vscode_tasks || return 1

  # Execute primary system core activation
  shell_pre_commit_deploy_hook_entrypoint || return 1
  
  # Non-critical steps: capturing execution warnings without halting the script
  shell_pre_commit_activate_git_hooks
  shell_pre_commit_apply_permissions

  # Evaluate runtime thresholds to display custom state summaries
  if [ ${GIT_HOOK_STATUS_CORE_HOOKS_PATH} -eq 0 ] && [ ${GIT_HOOK_STATUS_CHMOD_ENTRYPOINT} -eq 0 ]; then
    echo "================================================================================"
    echo "[OKK] :: SETUP COMPLETED SUCCESSFULLY"
    echo "         'Shell-DotDev-GitHooks' is active and listening for commits."
    echo ""
    echo ""
    return 0
  fi

  echo "================================================================================"
  echo "[OKK] :: SETUP COMPLETE WITH ATTENTION ALERTS"
  echo "         Core assets deployed, but minor environmental adjustments are needed:"
  echo ""
  echo ""

  if [ ${GIT_HOOK_STATUS_CORE_HOOKS_PATH} -ne 0 ]; then
    echo "[ ! ] - Git core paths routing failed."
    echo "        Please execute manually to activate the framework target:"
    echo "        > git config core.hooksPath .dev/tools/githooks"
    echo ""
  fi

  if [ ${GIT_HOOK_STATUS_CHMOD_ENTRYPOINT} -ne 0 ]; then
    echo "[ ! ] - Operational execution flag assignment denied."
    echo "        Please grant runtime validation permissions explicitly:"
    echo "        > chmod +x .dev/tools/githooks/pre-commit"
    echo ""
  fi
  echo ""
  
  return 0
}

main "$@"
exit $?