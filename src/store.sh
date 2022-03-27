#==============================================================================
#    _____ _
#   / ____| |
#  | (___ | |_ ___  _ __ ___
#   \___ \| __/ _ \| '__/ _ \
#   ____) | || (_) | | |  __/
#  |_____/ \__\___/|_|  \___|
#
#==============================================================================
# STORE
#==============================================================================

#==============================================================================
# The store system provides a way to globally store key-value pairs. Internally
# the store system will encode both the key and the value to be able to store
# multi-line values in any character-set.
#==============================================================================

# Separator string between the key and the value.
DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR=':'

# Global store system storage file.
DM_STORE__RUNTIME__STORAGE_FILE='__INVALID__'

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
# Initializes the store system by creating a new temporary file to be used as a
# store file.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] store_file_path - Path to the store file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   DM_STORE__RUNTIME__STORAGE_FILE
# STDOUT:
#   None
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_store__init() {
  ___store_file_path="$1"

  dm_store__debug '_dm_store__init' \
    'initializing store system..'

  DM_STORE__RUNTIME__STORAGE_FILE="$___store_file_path"

  if [ ! -f "$DM_STORE__RUNTIME__STORAGE_FILE" ]
  then
    ___dir="$(posix_adapter__dirname "$DM_STORE__RUNTIME__STORAGE_FILE")"
    posix_adapter__mkdir --parents "$___dir"
    posix_adapter__touch "$DM_STORE__RUNTIME__STORAGE_FILE"
  fi

  dm_store__debug_list '_dm_store__init' \
    "store system initialized with storage file path:" \
    "$DM_STORE__RUNTIME__STORAGE_FILE"
}

#==============================================================================
# Writes a value for a key to the store file.
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
_dm_store__set() {
  ___key="$1"
  ___value="$2"

  dm_store__debug_list '_dm_store__set' \
    "storing value for key '${___key}':" "$___value"

  dm_store__debug '_dm_store__set' 'encoding values..'

  ___encoded_key="$(_dm_store__encode "$___key")"
  ___encoded_value="$(_dm_store__encode "$___value")"

  dm_store__debug '_dm_store__set' 'storing values..'

  _dm_store__log_store_content 'store content before insertion'

  if _dm_store__key_exists "$___encoded_key"
  then
    _dm_store__replace "$___encoded_key" "$___encoded_value"
  else
    _dm_store__insert "$___encoded_key" "$___encoded_value"
  fi

  _dm_store__log_store_content 'store content after insertion'

  dm_store__debug '_dm_store__set' 'set finished'
}

#==============================================================================
# Gets the value for the given key.
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
#   Decoded value for the given key if exists.
# STDERR:
#   None
# Status:
#   0 - Key exists, value returned.
#   1 - Key does not exist.
#==============================================================================
_dm_store__get() {
  ___key="$1"

  dm_store__debug '_dm_store__get' "reading value for key '${___key}'"

  ___encoded_key="$(_dm_store__encode "$___key")"

  if ___encoded_value="$(_dm_store__get_value_for_key "$___encoded_key")"
  then
    ___value="$(_dm_store__decode "$___encoded_value")"
    posix_adapter__echo "$___value"
    dm_store__debug '_dm_store__get' 'get finished'
    return 0
  else
    dm_store__debug '_dm_store__get' 'get finished'
    return 1
  fi
}

#==============================================================================
# Decode and list all keys in the store.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__RUNTIME__STORAGE_FILE
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
#   0 - Keys are listed.
#   1 - Store is empty.
#==============================================================================
_dm_store__keys() {
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  dm_store__debug '_dm_store__keys' \
    'listing and decoding the keys in the store'

  if [ -s "$___store_file" ]
  then
    while read -r ___entry; do
      dm_store__debug '_dm_store__keys' 'separating key from entry..'

      ___encoded_key="$(_dm_store__get_key_from_entry "$___entry")"

      dm_store__debug '_dm_store__keys' 'decoding key..'

      ___key="$(_dm_store__decode "$___encoded_key")"

      dm_store__debug '_dm_store__keys' 'displaying key..'

      posix_adapter__echo "$___key"

    done <"$___store_file"

    dm_store__debug '_dm_store__keys' 'listing finished'

  else
    dm_store__debug '_dm_store__keys' 'store file is empty'
    return 1
  fi
}

#==============================================================================
# Decode and list the store file content.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__RUNTIME__STORAGE_FILE
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
#   0 - Store content is listed.
#   1 - Store is empty.
#==============================================================================
_dm_store__list() {
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  dm_store__debug '_dm_store__list' \
    'listing and decoding the content of the store line-by-line'

  if [ -s "$___store_file" ]
  then
    while read -r ___entry; do

      dm_store__debug '_dm_store__list' 'getting fields from entry..'
      ___encoded_key="$(_dm_store__get_key_from_entry "$___entry")"
      ___encoded_value="$(_dm_store__get_value_from_entry "$___entry")"

      dm_store__debug '_dm_store__list' 'decoding fields..'
      ___key="$(_dm_store__decode "$___encoded_key")"
      ___value="$(_dm_store__decode "$___encoded_value")"

      dm_store__debug '_dm_store__list' 'displaying fields..'
      posix_adapter__echo "'${___key}': '${___value}'"

    done <"$___store_file"

    dm_store__debug '_dm_store__list' 'listing finished'

  else
    dm_store__debug '_dm_store__list' 'store file is empty'
    return 1
  fi
}

#==============================================================================
# Delete the entry for the given key.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] key - Key to be deleted..
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
#   0 - Key exists, deletion completed.
#   1 - Key does not exist.
#==============================================================================
_dm_store__delete() {
  ___key="$1"

  dm_store__debug 'dm_store__delete' "reading value for key '${___key}'"

  _dm_store__log_store_content 'store content before deletion'

  ___encoded_key="$(_dm_store__encode "$___key")"

  _dm_store__delete_key "$___encoded_key"

  _dm_store__log_store_content 'store content after deletion'
}

#==============================================================================
#  ____       _            _         _          _
# |  _ \ _ __(_)_   ____ _| |_ ___  | |__   ___| |_ __   ___ _ __ ___
# | |_) | '__| \ \ / / _` | __/ _ \ | '_ \ / _ \ | '_ \ / _ \ '__/ __|
# |  __/| |  | |\ V / (_| | ||  __/ | | | |  __/ | |_) |  __/ |  \__ \
# |_|   |_|  |_| \_/ \__,_|\__\___| |_| |_|\___|_| .__/ \___|_|  |___/
#================================================|_|===========================
# PRIVATE HELPERS
#==============================================================================

#==============================================================================
# Logs out the content of the store file if debug is enabled.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] message - Debug message that should be used for the log message.
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
_dm_store__log_store_content() {
  ___message="$1"
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  if dm_store__config__debug_is_enabled
  then
    if [ -s "$___store_file" ]
    then
      dm_store__debug_list '_dm_store__log_store_content' \
        "$___message" \
        "$(posix_adapter__cat "$___store_file")"
    else
      dm_store__debug '_dm_store__log_store_content' 'store file is empty'
    fi
  fi
}

#==============================================================================
# Separates the key from the given entry.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] entry - Entry from the store file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Separated key.
# STDERR:
#   None
# Status:
#   0 - Separation completed.
#   1 - Error during separation.
#==============================================================================
_dm_store__get_key_from_entry() {
  ___entry="$1"

  dm_store__debug '_dm_store__get_key_from_entry' \
    'getting key from entry..' \

  _dm_store__get_field_from_entry "$___entry" '1'
}

#==============================================================================
# Separates the value from the given entry.
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] entry - Entry from the store file.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Separated value.
# STDERR:
#   None
# Status:
#   0 - Separation completed.
#   1 - Error during separation.
#==============================================================================
_dm_store__get_value_from_entry() {
  ___entry="$1"

  dm_store__debug '_dm_store__get_value_from_entry' \
    'getting value from entry..' \

  _dm_store__get_field_from_entry "$___entry" '2'
}

#==============================================================================
# Separates the given field from the given store entry.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR
# Arguments:
#   [1] entry - Entry from the store file.
#   [2] field_index - Field index starting from one.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Separated field.
# STDERR:
#   None
# Status:
#   0 - Separation completed.
#   1 - Error during separation.
#==============================================================================
_dm_store__get_field_from_entry() {
  ___entry="$1"
  ___field_index="$2"

  ___separator="$DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR"

  dm_store__debug_list '_dm_store__get_field_from_entry' \
    "getting field '${___field_index}' from entry" \
    "$___entry"

  if ___field="$( \
    posix_adapter__echo "$___entry" | \
    posix_adapter__cut --delimiter "$___separator" --fields "$___field_index" \
  )"
  then
    dm_store__debug '_dm_store__get_field_from_entry' \
      "field separated: '${___field}'"
    posix_adapter__echo "$___field"
  else
    dm_store__debug '_dm_store__get_field_from_entry' \
      'error during field separation..'
    return 1
  fi
}

#==============================================================================
# Checks if the given key exists in the storage file.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] key - The key that has to be checked.
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
#   0 - Key found.
#   1 - Key not fount.
#==============================================================================
_dm_store__key_exists() {
  ___key="$1"

  ___separator="$DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  ___pattern="^${___key}${___separator}"

  if posix_adapter__grep --silent "$___pattern" "$___store_file"
  then
    dm_store__debug '_dm_store__key_exists' 'key found in the store'
    return 0
  else
    dm_store__debug '_dm_store__key_exists' \
      'key does not exist in the store'
    return 1
  fi
}

#==============================================================================
# Gets the value from the store for a key is exists.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] key - The key for the value that should be returned.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Value if exists.
# STDERR:
#   None
# Status:
#   0 - Key found, value returned.
#   1 - Key not fount.
#   2 - Unexpected error, it should be reported..
#==============================================================================
_dm_store__get_value_for_key() {
  ___key="$1"

  ___separator="$DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  ___search_pattern="^${___key}${___separator}"

  if ___result="$(posix_adapter__grep "$___search_pattern" "$___store_file")"
  then
    dm_store__debug_list '_dm_store__get_value_for_key' \
      'key found in the store:' "$___result"

    # This is a very unlikely case, but should be prepared for it..
    ___line_count="$(posix_adapter__echo "$___result" | posix_adapter__wc --lines)"
    if [ "$___line_count" -ne '1' ]
    then
      dm_store__debug_list '_dm_store__store__get_value_for_key' \
        'unexpected error! more then one matching line found' \
        "$___result"
      return 2
    fi

    # Want to remain fully POSIX compliante, variable expansion is not required
    # by POSIX, so we won't use it here instead of the echo-sed combination.
    # Read more: https://stackoverflow.com/a/21913014/1565331
    # shellcheck disable=SC2001
    ___value="$( \
      posix_adapter__echo "$___result" | \
      posix_adapter__sed --expression "s/${___search_pattern}//" \
    )"

    dm_store__debug_list '_dm_store__get_value_for_key' \
      'value separated:' "$___value"

    posix_adapter__echo "$___value"
    return 0

  else
    dm_store__debug '_dm_store__get_value_for_key' \
      'key does not exist in the store, returning (1)..'
    return 1
  fi
}

#==============================================================================
# Inserts the given key-value pair to the store by appending it to the store
# file.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_STORE__RUNTIME__STORAGE_FILE
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
_dm_store__insert() {
  ___key="$1"
  ___value="$2"

  ___separator="$DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  dm_store__debug '_dm_store__insert' \
    'inserting key-value pair to the store file..'

  ___line="${___key}${___separator}${___value}"
  posix_adapter__echo "$___line" >> "$___store_file"

  dm_store__debug '_dm_store__insert' \
    'key-value pair has been inserted to the store file'
}

#==============================================================================
# Replaces an existing key with new a key-value pair to the store.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_STORE__RUNTIME__STORAGE_FILE
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
_dm_store__replace() {
  ___key="$1"
  ___value="$2"

  ___separator="$DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  dm_store__debug '_dm_store__replace' \
    'replacing existing key with new value..'

  ___pattern="^${___key}${___separator}.*"
  ___new="${___key}${___separator}${___value}"

  posix_adapter__sed \
    --in-place '' \
    --expression "s/${___pattern}/${___new}/" \
    "$___store_file"

  dm_store__debug '_dm_store__replace' 'value has been replaced'
}

#==============================================================================
# Deletes an entry that matches for the given key.
#------------------------------------------------------------------------------
# Globals:
#   DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR
#   DM_STORE__RUNTIME__STORAGE_FILE
# Arguments:
#   [1] key - Key for the entry to be deleted.
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
#   1 - Key does not exist.
#==============================================================================
_dm_store__delete_key() {
  ___key="$1"

  ___separator="$DM_STORE__CONSTANT__KEY_VALUE_SEPARATOR"
  ___store_file="$DM_STORE__RUNTIME__STORAGE_FILE"

  dm_store__debug '_dm_store__delete_key' \
    "deleting key '${___key}'.."

  if _dm_store__key_exists "$___key"
  then
    ___pattern="^${___key}${___separator}.*"
    posix_adapter__sed \
      --in-place '' \
      --expression "/${___pattern}/d" \
      "$___store_file"
    dm_store__debug '_dm_store__delete_key' 'key deleted'
  else
    dm_store__debug '_dm_store__delete_key' 'key does not exist!'
    return 1
  fi
}

#==============================================================================
# Encodes the given input to be able to store in a failsafe way by generating a
# single line of hexadecimal dump. In this way any multiline text can be stored
# in a single line in the storage file.
# Example: 'hello world\n' -> '68656c6c6f20776f726c640a'
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] value - Value that needs to be encoded.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Encoded input value.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_store__encode() {
  ___value="$1"

  dm_store__debug_list '_dm_store__encode' \
    'encoding value:' "$___value"

  ___encoded="$( \
    posix_adapter__echo "$___value" | \
    posix_adapter__xxd --plain | \
    posix_adapter__tr --delete '\n' \
  )"

  dm_store__debug_list '_dm_store__encode' \
    'value encoded:' "$___encoded"

  posix_adapter__echo "$___encoded"
}

#==============================================================================
# Decodes the previously decoded text.
# Example: '68656c6c6f20776f726c640a' -> 'hello world\n'
#------------------------------------------------------------------------------
# Globals:
#   None
# Arguments:
#   [1] encoded_value - Encoded value that needs to be decoded.
# STDIN:
#   None
#------------------------------------------------------------------------------
# Output variables:
#   None
# STDOUT:
#   Decoded value.
# STDERR:
#   None
# Status:
#   0 - Other status is not expected.
#==============================================================================
_dm_store__decode() {
  ___encoded_value="$1"

  dm_store__debug_list '_dm_store__decode' \
    'decoding value:' "$___encoded_value"

  ___value="$( \
    posix_adapter__echo "$___encoded_value" | \
    posix_adapter__xxd --revert --plain \
  )"

  dm_store__debug_list '_dm_store__decode' \
    'value decoded:' "$___value"

  posix_adapter__echo "$___value"
}
