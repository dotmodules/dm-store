#==============================================================================
# STORE MANAGEMENT CASES
#==============================================================================

#==============================================================================
# The store system has to reliably store and retrieve any kind of textual
# input. It is doing it by encoding both the key and the value. In this way
# egzotic characters and multilite textual inputs are not an issue.
#==============================================================================

# Path to the store file.
TEMP_STORE_FILE_PATH='./temp.store'

#==============================================================================
# VALID CASES
#==============================================================================
posix_store__test__valid_case 'store - single words can be stored and retrieved'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"
value="value"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key" "$value"

expected="$value"

if result="$(posix_store__get "$key")"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - multi word keys and values can be used'

rm -f "$TEMP_STORE_FILE_PATH"

key="my key"
value="my value"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key" "$value"

expected="$value"

if result="$(posix_store__get "$key")"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - setting the key again overrides old value'

rm -f "$TEMP_STORE_FILE_PATH"

key="my key"
old_value="my old value"
new_value="my new value"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key" "$old_value"
posix_store__set "$key" "$new_value"

expected="$new_value"

if result="$(posix_store__get "$key")"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - setting the key multiple times wont create new entry'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key" '1'
posix_store__set "$key" '2'
posix_store__set "$key" '3'
posix_store__set "$key" '4'
posix_store__set "$key" '5'
posix_store__set "$key" '6'
posix_store__set "$key" '7'
posix_store__set "$key" '8'
posix_store__set "$key" '9'

expected='1'

if result="$(posix_adapter__wc --lines < "$POSIX_STORE__RUNTIME__STORAGE_FILE")"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - multiline values can be stored 1'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"
value_1='line 1'
value_2='line 2'
value="$( \
  echo "$value_1"; \
  echo "$value_2"; \
)"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key" "$value"

expected='2'

if result="$(posix_store__get "$key" | posix_adapter__wc --lines)"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

posix_store__test__valid_case 'store - multiline values can be stored 2'

expected="$value_1"

if result="$(posix_store__get "$key" | posix_adapter__sed --expression '1q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

posix_store__test__valid_case 'store - multiline values can be stored 3'

expected="$value_2"

if result="$(posix_store__get "$key" | posix_adapter__sed --expression '2q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - even multiline keys can be used 1'

rm -f "$TEMP_STORE_FILE_PATH"

key="$( \
  echo 'key line 1'; \
  echo 'key line 2'; \
)"
value_1='line 1'
value_2='line 2'
value="$( \
  echo "$value_1"; \
  echo "$value_2"; \
)"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key" "$value"

expected='2'

if result="$(posix_store__get "$key" | posix_adapter__wc --lines)"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - even multiline keys can be used 2'

expected="$value_1"

if result="$(posix_store__get "$key" | posix_adapter__sed --expression '1q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - even multiline keys can be used 3'

expected="$value_2"

if result="$(posix_store__get "$key" | posix_adapter__sed --expression '2q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - keys can be listed 1'

rm -f "$TEMP_STORE_FILE_PATH"

key_1="key_1"
key_2="key_2"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key_1" 'value'
posix_store__set "$key_2" 'value'

expected='2'

if result="$(posix_store__keys | posix_adapter__wc --lines)"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - keys can be listed 2'

expected="$key_1"

if result="$(posix_store__keys | posix_adapter__sed --expression '1q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - keys can be listed 3'

expected="$key_2"

if result="$(posix_store__keys | posix_adapter__sed --expression '2q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - entries can be listed 1'

rm -f "$TEMP_STORE_FILE_PATH"

key_1="key_1"
key_2="key_2"
value_1="value_1"
value_2="value_2"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key_1" "$value_1"
posix_store__set "$key_2" "$value_2"

expected='2'

if result="$(posix_store__list | posix_adapter__wc --lines)"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - entries can be listed 2'

expected="'${key_1}': '${value_1}'"

if result="$(posix_store__list | posix_adapter__sed --expression '1q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - entries can be listed 3'

expected="'${key_2}': '${value_2}'"

if result="$(posix_store__list | posix_adapter__sed --expression '2q;d')"
then
  posix_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - entry can be deleted by key'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"

posix_store__init "$TEMP_STORE_FILE_PATH"
posix_store__set "$key" 'value'

if posix_store__delete "$key"
then
  if posix_store__get "$key"
  then
    # Deleted key should not be retrievable.
    posix_store__test__test_case_failed '0'
  else
    posix_store__test__test_case_passed
  fi
else
  status="$?"
  posix_store__test__test_case_failed "$status"
fi

#==============================================================================
posix_store__test__valid_case 'store - nonexistent key cannot be retrieved'

rm -f "$TEMP_STORE_FILE_PATH"

posix_store__init "$TEMP_STORE_FILE_PATH"

if posix_store__get "invalid-key"
then
  # Invalid key should not be retrievable.
  posix_store__test__test_case_failed '0'
else
  posix_store__test__test_case_passed
fi

#==============================================================================
posix_store__test__valid_case 'store - empty store - keys cannot be listed'

rm -f "$TEMP_STORE_FILE_PATH"

posix_store__init "$TEMP_STORE_FILE_PATH"

if posix_store__keys
then
  # Invalid key should not be retrievable.
  posix_store__test__test_case_failed '0'
else
  posix_store__test__test_case_passed
fi

#==============================================================================
posix_store__test__valid_case 'store - empty store - entries cannot be listed'

rm -f "$TEMP_STORE_FILE_PATH"

posix_store__init "$TEMP_STORE_FILE_PATH"

if posix_store__list
then
  # Invalid key should not be retrievable.
  posix_store__test__test_case_failed '0'
else
  posix_store__test__test_case_passed
fi

#==============================================================================
# CLEANUP
#==============================================================================

rm -f "$TEMP_STORE_FILE_PATH"
