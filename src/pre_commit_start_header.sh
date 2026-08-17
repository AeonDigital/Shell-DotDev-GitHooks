#!/usr/bin/env bash

# shell_pre_commit_start_header — Renders workspace diagnostics and aligned telemetry
# states mapping active configuration toggles with their respective operational effects.
# 
# Description:
# - Formats and outputs the baseline structural framework information (paths, scripts,
#   and runtime clock).
# - Inspects variable types via 'declare -p' to aggressively suppress array structures
#   from logging.
# - Dynamically groups variables sharing a common corporate prefix into a visually
#   cohesive "family" block without compromising the sequence order of the master
#   register.
# - Enforces a clean, left-aligned indented layout for family members (2 spaces from
#   prefix) while maintaining perfect vertical symmetry for the variable state values
#   column.
# 
# Arguments:
# - None. (Relies on upstream global configuration arrays and operational registers).
# 
# Returns:
# - Renders a structured diagnostic telemetry summary directly to stdout.
# 
# Return Codes:
# - 0: On successful structured telemetry output formatting.
shell_pre_commit_start_header() {
  local cur_datetime=$(date +"%Y-%m-%d %H:%M:%S")

  echo "================================================================================"
  echo "[RUN] STARTING PRE-COMMIT"
  echo ""
  echo "      Root_Path : ${GIT_HOOK_PROJECT_ROOT_PATH}"
  echo "         Script : ${GIT_HOOK_TOOLS_PATH}/pre-commit"
  echo "       DateTime : ${cur_datetime}"
  echo ""
  echo " Configurations :"

  # Define here the prefixes you want to group as dynamic families
  local -a family_prefixes=(
    "GIT_HOOK_ACTIVE_PACKAGE"
  )

  local var_name=""
  local var_metadata=""
  local prefix=""
  local is_family_member=""

  # Step 1: Pre-process the register to build a clean index of valid scalar variables
  # and determine exactly where the first occurrence of each family tracker triggers.
  local -a valid_vars=()
  local -A family_first_trigger=()

  for var_name in "${GIT_HOOK_GLOBAL_VAR_REGISTER[@]}"; do
    if [ "${var_name}" = "GIT_HOOK_PROJECT_ROOT_PATH" ]; then
      continue
    fi

    # Suppress arrays dynamically
    var_metadata=$(declare -p "${var_name}" 2>/dev/null)
    if [[ "${var_metadata}" =~ ^declare\ -[aA] ]]; then
      continue
    fi

    valid_vars+=("${var_name}")

    # Detect family matching and tag the absolute pioneer variable of that family
    for prefix in "${family_prefixes[@]}"; do
      if [[ "${var_name}" =~ ^"${prefix}" ]]; then
        if [ -z "${family_first_trigger[${prefix}]+x}" ]; then
          family_first_trigger["${prefix}"]="${var_name}"
        fi
        break
      fi
    done
  done

  # Step 2: Main loop rendering with structural visual boundaries and precise spacing
  local current_value=""
  local dict_entry=""
  local trigger_state=""
  local effect_message=""
  local display_label=""
  local last_was_family="false"
  local -A family_header_printed=()

  local padding_size=0
  local spaces_buffer=""

  for var_name in "${valid_vars[@]}"; do
    is_family_member="false"
    prefix=""

    # Verify if this variable falls under a managed family prefix
    for p in "${family_prefixes[@]}"; do
      if [[ "${var_name}" =~ ^"${p}" ]]; then
        is_family_member="true"
        prefix="${p}"
        break
      fi
    done

    current_value="${!var_name}"
    dict_entry="${GIT_HOOK_GLOBAL_VAR_STATUS_MESSAGE[${var_name}]:--}"
    effect_message=""

    # Parses the dictionary token if a dynamic configuration map exists
    if [ "${dict_entry}" != "-" ]; then
      trigger_state="${dict_entry%%::*}"
      if [ "${current_value}" = "${trigger_state}" ]; then
        effect_message="-> ${dict_entry#*::}"
      fi
    fi

    # Render Block Logic
    if [ "${is_family_member}" = "true" ]; then
      # If this is the absolute first member of the family, open an elegant section
      # line break and print the leading global family prefix anchor.
      if [ "${var_name}" = "${family_first_trigger[${prefix}]}" ] && [ -z "${family_header_printed[${prefix}]+x}" ]; then
        echo ""
        printf "    %s\n" "${prefix}"
        family_header_printed["${prefix}"]="true"
      fi

      # Strip the core prefix family name from the variable to isolate the child
      # label
      display_label="${var_name#$prefix}"
      display_label="${display_label#_}"

      # CALCULATE DYNAMIC PADDING: Target width is 30. We subtract the length of
      # the string to find the missing spaces. Since we already indented 2 extra
      # spaces at the start (6 spaces total vs 4 from root), the available space
      # for the text field before the '=' is exactly 28 spaces.
      padding_size=$((28 - ${#display_label}))

      # Generates a string with the exact number of required spaces
      spaces_buffer=$(printf '%*s' "${padding_size}" "")

      # Layout alignment formatting specs (Dynamic Left-Aligned): Renders exactly
      # 6 spaces, the label, the calculated padding spaces, and the '=' icon.
      printf "      %s%s = %-7s %s\n" "${display_label}" "${spaces_buffer}" "'${current_value}'" "${effect_message}"

      # Tracks state to enable dynamic spacing boundaries
      last_was_family="true"
    else
      # If transitioning from a family cluster back to standard root elements, inject
      # a trailing space delimiter
      if [ "${last_was_family}" = "true" ]; then
        echo ""
        last_was_family="false"
      fi

      # standard root element rendering layout
      display_label="${var_name}"
      printf "    %-30s = %-7s %s\n" "${display_label}" "'${current_value}'" "${effect_message}"
    fi
  done

  echo ""
  echo ""
  return 0
}
