#!/usr/bin/env bash

# shell_pre_commit_package_import — Master orchestrator that iterates over the registered
# upstream dependencies and triggers their individual network provisioning pipelines.
# 
# Description:
# - Scans the 'IMPORT_PACKAGE_REGISTER' indexed array to discover all external tool
#   dependencies.
# - Dynamically normalizes each package token to match Bash variable naming constraints
#   (converting to uppercase and translating hyphens to underscores).
# - Resolves the corresponding target associative configuration array using a nominal
#   reference (nameref).
# - Verifies configuration presence and dispatches the metadata to the core remote
#   package installer engine, aborting the entire pipeline immediately if any download
#   or check fails.
# 
# Arguments:
# - None. (Relies on the global 'IMPORT_PACKAGE_REGISTER' array and dynamically mapped
#   global associative arrays).
# 
# Returns:
# - Sequentially triggers 'shell_pre_commit_package_installer' for each registered
#   dependency.
# 
# Return Codes:
# - 0: On successful discovery, network transport, verification, and caching of all
#   packages.
# - 1: If any individual package installer pipeline fails or encounters structural
#   setup errors.
shell_pre_commit_package_import() {
  local package_token=""
  local assoc_name=""
  local import_status=""
  local step_counter=1

  for package_token in "${IMPORT_PACKAGE_REGISTER[@]}"; do
    assoc_name="${package_token^^}"
    assoc_name="IMPORT_PACKAGE_${assoc_name//-/_}"

    # Verify if the dynamically generated associative array variable exists before
    # attempting to declare a nameref against it.
    if ! declare -p "${assoc_name}" &>/dev/null; then
      echo "[ERR] :: Assoc array '${assoc_name}' not exists for upstream package importing!"
      echo "         Set it as the configuration for the respective dependency "
      echo "         or remove it from the 'IMPORT_PACKAGE_REGISTER' registry."
      return 1
    fi

    local -n current_import="${assoc_name}"

    # Trigger the downstream installer passing parameters securely from the associative
    # schema. Appends a dynamic ">> STEP X" interface header based on loop progression.
    shell_pre_commit_package_installer \
      "${current_import["upstream_base_url"]}" \
      "${current_import["package_name"]}" \
      "${current_import["package_filename"]}" \
      "${GIT_HOOK_ACTIVE_PACKAGE_AUTOUPDATE}" \
      ">> STEP ${step_counter} :: Provisioning ${current_import["package_name"]} Core"

    import_status=$?
    unset -n current_import

    if [ ${import_status} -ne 0 ]; then
      return 1
    fi

    ((step_counter++))
  done

  return 0
}
