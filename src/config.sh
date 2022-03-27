#==============================================================================
#   _____             __ _                       _   _
#  / ____|           / _(_)                     | | (_)
# | |     ___  _ __ | |_ _  __ _ _   _ _ __ __ _| |_ _  ___  _ __
# | |    / _ \| '_ \|  _| |/ _` | | | | '__/ _` | __| |/ _ \| '_ \
# | |___| (_) | | | | | | | (_| | |_| | | | (_| | |_| | (_) | | | |
#  \_____\___/|_| |_|_| |_|\__, |\__,_|_|  \__,_|\__|_|\___/|_| |_|
#                           __/ |
#==========================|___/===============================================

#==============================================================================
#   __  __                 _       _
#  |  \/  |               | |     | |
#  | \  / | __ _ _ __   __| | __ _| |_ ___  _ __ _   _
#  | |\/| |/ _` | '_ \ / _` |/ _` | __/ _ \| '__| | | |
#  | |  | | (_| | | | | (_| | (_| | || (_) | |  | |_| |
#  |_|  |_|\__,_|_| |_|\__,_|\__,_|\__\___/|_|   \__, |
#                                                 __/ |
#================================================|___/=========================
# MANDATORY CONFIGURATION VARIABLES
#==============================================================================

#==============================================================================
#  ____       _   _                       __ _
# |  _ \ __ _| |_| |__    _ __  _ __ ___ / _(_)_  __
# | |_) / _` | __| '_ \  | '_ \| '__/ _ \ |_| \ \/ /
# |  __/ (_| | |_| | | | | |_) | | |  __/  _| |>  <
# |_|   \__,_|\__|_| |_| | .__/|_|  \___|_| |_/_/\_\
#========================|_|===================================================
# SUBMODULE PATH PREFIX
#==============================================================================
# For better readability posix_store.sh is composed from smaller scripts that
# are sourced into it dynamically. As posix_store.sh is imported to the user
# codebase by sourcing, the conventional path determination cannot be used. The
# '$0' variable contains the the host script's path posix_store.sh is sourced
# from. The relative path from the sourceing code to the root of the
# posix-store subrepo has to be defined explicitly to the internal sourcing
# could be executed.
POSIX_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX=\
"${POSIX_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX:=__INVALID__}"

#==============================================================================
#    ____        _   _                   _
#   / __ \      | | (_)                 | |
#  | |  | |_ __ | |_ _  ___  _ __   __ _| |
#  | |  | | '_ \| __| |/ _ \| '_ \ / _` | |
#  | |__| | |_) | |_| | (_) | | | | (_| | |
#   \____/| .__/ \__|_|\___/|_| |_|\__,_|_|
#         | |
#=========|_|==================================================================
# OPTIONAL CONFIGURATION VARIABLES
#==============================================================================

#==============================================================================
#  ____       _                                       _
# |  _ \  ___| |__  _   _  __ _   _ __ ___   ___   __| | ___
# | | | |/ _ \ '_ \| | | |/ _` | | '_ ` _ \ / _ \ / _` |/ _ \
# | |_| |  __/ |_) | |_| | (_| | | | | | | | (_) | (_| |  __/
# |____/ \___|_.__/ \__,_|\__, | |_| |_| |_|\___/ \__,_|\___|
#=========================|___/================================================
# DEBUG MODE
#==============================================================================
# Debug mode enabled or not..
POSIX_STORE__CONFIG__OPTIONAL__DEBUG_ENABLED=\
"${POSIX_STORE__CONFIG__OPTIONAL__DEBUG_ENABLED:=0}"

#==============================================================================
# Helper function to check if debugging is enabled or not.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_STORE__CONFIG__OPTIONAL__DEBUG_ENABLED
# Arguments:
#   None
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
#   0 - debug mode is enabled
#   1 - debug mode is disabled
#==============================================================================
posix_store__config__debug_is_enabled() {
  test "$POSIX_STORE__CONFIG__OPTIONAL__DEBUG_ENABLED" -ne '0'
}

#==============================================================================
#  __      __   _ _     _       _   _
#  \ \    / /  | (_)   | |     | | (_)
#   \ \  / /_ _| |_  __| | __ _| |_ _  ___  _ __
#    \ \/ / _` | | |/ _` |/ _` | __| |/ _ \| '_ \
#     \  / (_| | | | (_| | (_| | |_| | (_) | | | |
#      \/ \__,_|_|_|\__,_|\__,_|\__|_|\___/|_| |_|
#
#==============================================================================
# CONFIGURATION VALIDATION
#==============================================================================

#==============================================================================
# Configuration variables are mandatory, therefore a check need to be executed
# to ensure that the configuration is complete.
#------------------------------------------------------------------------------
# Globals:
#   POSIX_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX
# Arguments:
#   None
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
posix_store__config__validate_mandatory_config() {
  posix_store__debug 'posix_store__config__validate_mandatory_config' \
    'validating mandatory configuration variables..'

  if [ "$POSIX_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX" = '__INVALID__' ]
  then
    _posix_store__config__report_configuration_error \
      'POSIX_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX'
  fi

  posix_store__debug 'posix_store__config__validate_mandatory_config' \
    'configuration is complete'
}

#==============================================================================
# Error reporting helper function. Prints out the error message, then exits
# with error.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] variable - Missing variable name.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   None
# STDERR:
#   Error message about the missing configuration variable.
# Status:
#   1 - Exiting with error after printed out the issue.
#==============================================================================
_posix_store__config__report_configuration_error() {
  ___variable="$1"

  posix_store__debug '_posix_store__config__report_configuration_error' \
    'configuration error detected!'

  posix_store__report_error_and_exit \
    'Configuration validation failed!' \
    'Mandatory configuration variable was not configured:' \
    "$___variable"
}
