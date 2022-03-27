#!/bin/sh
# Expressions don't expand inside single quotes.
# shellcheck disable=SC2016
# Single quote escapement.
# shellcheck disable=SC1003
# Single quote escapement.
# shellcheck disable=SC2034

#==============================================================================
# SANE ENVIRONMENT
#==============================================================================

set -e  # exit on error
set -u  # prevent unset variable expansion

#==============================================================================
# PATH CHANGE
#==============================================================================

# This is the only part where the code has to be prepared for missing tool
# capabilities. It is known that on MacOS readlink does not support the -f flag
# by default.
if target_path="$(readlink -f "$0" 2>/dev/null)"
then
  cd "$(dirname "$target_path")"
else
  # If the path cannot be determined with readlink, we have to check if this
  # script is executed through a symlink or not.
  if [ -L "$0" ]
  then
    # If the current script is executed through a symlink, we are out of luck,
    # because without readlink, there is no universal solution for this problem
    # that uses the default shell toolset.
    echo "symlinked script won't work on this machine.."
  else
    cd "$(dirname "$0")"
  fi
fi

#==============================================================================
# COMMON TEST SUITE LIB
#==============================================================================

. ./common.sh

#==============================================================================
# TEST RUNNER IMPORT
#==============================================================================

# Relative path from the current path to the dm store repo root.
DM_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX='..'

# shellcheck source=../dm.store.sh
. "${DM_STORE__CONFIG__MANDATORY__SUBMODULE_PATH_PREFIX}/dm.store.sh"

#==============================================================================
# ENTRY POINT
#==============================================================================

posix_adapter__printf '%s' '======================================================='
posix_adapter__printf '%s\n' '============================='
posix_adapter__echo 'COMMON TEST TOOLS VERIFICATIONS'
posix_adapter__printf '%s' '======================================================='
posix_adapter__printf '%s\n' '============================='

. ./test__common.sh

posix_adapter__printf '%s' '======================================================='
posix_adapter__printf '%s\n' '============================='
posix_adapter__echo 'STORE TEST CASES'
posix_adapter__printf '%s' '======================================================='
posix_adapter__printf '%s\n' '============================='

DM_STORE__CONFIG__OPTIONAL__DEBUG_ENABLED='0'

. ./test__store.sh

#==============================================================================
# SHELLCHECK VALIDATION
#==============================================================================

run_shellcheck() {
  dm_store__test__log_task 'running shellcheck..'
  # Specifying shell type here to be able to omit the shebangs from the
  # modules. More info: https://github.com/koalaman/shellcheck/wiki/SC2148
  shellcheck --shell=sh -x ../src/*.sh ../bin/* ./*.sh
  dm_store__test__log_success 'shellcheck finished'
}

if command -v shellcheck >/dev/null
then
  run_shellcheck
else
  posix_adapter__echo "WARNING: shellcheck won't be executed as it cannot be found."
fi
