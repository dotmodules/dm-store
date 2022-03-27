#!/bin/sh
#==============================================================================
#                   _              _                       _
#                  (_)            | |                     | |
#   _ __   ___  ___ ___  __    ___| |_ ___  _ __ ___   ___| |__
#  | '_ \ / _ \/ __| \ \/ /   / __| __/ _ \| '__/ _ \ / __| '_ \
#  | |_) | (_) \__ \ |>  < ___\__ \ || (_) | | |  __/_\__ \ | | |
#  | .__/ \___/|___/_/_/\_|___|___/\__\___/|_|  \___(_)___/_| |_|
#  | |
#==|_|=========================================================================

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# MAIN ERROR HANDLING ASSERTION FUNCTION
#==============================================================================

#==============================================================================
# Error reporting function that will display the given message and abort the
# execution. This needs to be defined in the highest level to be able to use it
# without sourcing the sub files.
#------------------------------------------------------------------------------
# Globals:
#   RED
#   BOLD
#   RESET
# Arguments:
#   [1] message - Error message that will be displayed.
#   [2] details - Detailed error message.
#   [3] reason - Reason of this error.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Error message.
# STDERR:
#   None
# Status:
#   1 - System will exit at the end of this function.
#------------------------------------------------------------------------------
# Tools:
#   echo sed
#==============================================================================
dm_store__report_error_and_exit() {
  ___message="$1"
  ___details="$2"
  ___reason="$3"

  # This function might be called before the global coloring valriables gets
  # initialized, hence the default value setting.
  RED="${RED:=}"
  BOLD="${BOLD:=}"
  RESET="${RESET:=}"

  >&2 printf '%s=======================================================' "$RED"
  >&2 echo "========================${RESET}"
  >&2 echo "  ${RED}${BOLD}FATAL ERROR${RESET}"
  >&2 printf '%s=======================================================' "$RED"
  >&2 echo "========================${RESET}"
  >&2 echo ''
  >&2 echo "  ${RED}${___message}${RESET}"
  >&2 echo "  ${RED}${___details}${RESET}"
  >&2 echo ''
  # Running in a subshell to keep line length below 80.
  # shellcheck disable=SC2005
  >&2 echo "$( \
    echo "${___reason}" | sed "s/^/  ${RED}/" | sed "s/$/${RESET}/" \
  )"
  >&2 echo ''
  >&2 printf '%s=======================================================' "$RED"
  >&2 echo "========================${RESET}"

  exit 1
}

#==============================================================================
# GLOBAL PATH PREFIX
#==============================================================================

#==============================================================================
# For better readability posix_store.sh is composed from smaller scripts that
# are sourced into it dynamically. As posix_store.sh is imported to the user
# codebase by sourcing, the conventional path determination cannot be used. The
# '$0' variable contains the the host script's path posix_store.sh is sourced
# from. The relative path from the sourceing code to the root of the
# posix_store subrepo has to be defined explicitly to the internal sourcing
# could be executed.
#==============================================================================

if [ -z ${DM_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX+x} ]
then
  dm_store__report_error_and_exit \
    'Initialization failed!' \
    'Mandatory path prefix variable is missing!' \
    'DM_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX'
fi

___path_prefix="${DM_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}"

#==============================================================================
# POSIX_ADAPTER INTEGRATION
#==============================================================================

if [ -z ${POSIX_ADAPTER+x} ]
then
  # If posix_adapter has not sourced yet, we have to source it from this repository.
  ___posix_adapter_path_prefix="${___path_prefix}/dependencies/posix-adapter"
  POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX="$___posix_adapter_path_prefix"
  if [ -d  "$POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" ]
  then
    # shellcheck source=./dependencies/posix_adapter/posix_adapter.sh
    . "${POSIX_ADAPTER__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/posix_adapter.sh"
  else
    dm_store__report_error_and_exit \
      'Initialization failed!' \
      'posix_adapter needs to be initialized but its git submodule is missing!' \
      'You need to source it or init its submodule here: git submodule init'
  fi
fi

# IMPORTANT: After this, every non shell built-in command should be called
# through the provided posix_adapter API to ensure the compatibility on
# different environments.

#==============================================================================
# SOURCING SUBMODULES
#==============================================================================

# shellcheck source=./src/debug.sh
. "${___path_prefix}/src/debug.sh"

# shellcheck source=./src/config.sh
. "${___path_prefix}/src/config.sh"

# shellcheck source=./src/store.sh
. "${___path_prefix}/src/store.sh"

#==============================================================================
#     _    ____ ___    __                  _   _
#    / \  |  _ \_ _|  / _|_   _ _ __   ___| |_(_) ___  _ __  ___
#   / _ \ | |_) | |  | |_| | | | '_ \ / __| __| |/ _ \| '_ \/ __|
#  / ___ \|  __/| |  |  _| |_| | | | | (__| |_| | (_) | | | \__ \
# /_/   \_\_|  |___| |_|  \__,_|_| |_|\___|\__|_|\___/|_| |_|___/
#==============================================================================
# API FUNCTIONS
#==============================================================================

#==============================================================================
# Debug wrapper function for the store init function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] store_file_path - Path to the store file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_store__init() {
  ___store_file_path="$1"

  dm_store__debug__wrapper '_dm_store__init' "$___store_file_path"
}

#==============================================================================
# Debug wrapper function for the store set function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] key - Key for the given value to be stored in.
#   [2] value - Value that needs to be stored for the given key.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_store__set() {
  ___key="$1"
  ___value="$2"

  dm_store__debug__wrapper '_dm_store__set' "$___key" "$___value"
}

#==============================================================================
# Debug wrapper function for the store get function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] key - Key for the given value to be retrieved with.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Value for the given key if exists.
# STDERR:
#   None
# Status:
#   0 - Key exists, value returned.
#   1 - Key does not exist.
#==============================================================================
dm_store__get() {
  ___key="$1"

  dm_store__debug__wrapper '_dm_store__get' "$___key"
}

#==============================================================================
# Debug wrapper function for the store keys function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Store file content.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_store__keys() {
  dm_store__debug__wrapper '_dm_store__keys'
}

#==============================================================================
# Debug wrapper function for the store list function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   None
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Store file content.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
dm_store__list() {
  dm_store__debug__wrapper '_dm_store__list'
}

#==============================================================================
# Debug wrapper function for the store delete function.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] key - The deletable key.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Key exists and delete was susseccful.
#   1 - Key does not exist.
#==============================================================================
dm_store__delete() {
  ___key="$1"

  dm_store__debug__wrapper '_dm_store__delete' "$___key"
}

#==============================================================================
# ENTRY POINT
#==============================================================================

dm_store__config__validate_mandatory_config
