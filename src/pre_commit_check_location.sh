#!/usr/bin/env bash

# shell_pre_commit_check_location — Validates the execution context to ensure the
# script runs exclusively from the absolute root directory of the active Git repository.
# 
# Description:
# - Performs a real-time query to the Git architecture to resolve the top-level repository
#   pathway.
# - Compares the resolved repository root against the current working directory ($PWD)
#   to block subshell navigation bypasses or accidental deep-nested path executions.
# - Aborts execution with a detailed fatal diagnostics report if the environment
#   is not a Git workspace or if executed from an invalid nested subdirectory.
# 
# Arguments:
# - None. (Discovers environmental states dynamically via native Git binary lookups).
# 
# Returns:
# - Renders a structured fatal error block to stderr/stdout if structural spatial
#   validation fails.
# 
# Return Codes:
# - 0: On perfect architectural alignment (Current path matches the Git repository
#   top-level root).
# - 1: If executed outside a Git workspace or from any nested structural subdirectory.
shell_pre_commit_check_location() {
  local repodir="$(git rev-parse --show-toplevel 2>/dev/null)"

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
