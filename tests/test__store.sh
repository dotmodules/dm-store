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
dm_store__test__valid_case 'store - single words can be stored and retrieved'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"
value="value"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key" "$value"

expected="$value"

if result="$(dm_store__get "$key")"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - multi word keys and values can be used'

rm -f "$TEMP_STORE_FILE_PATH"

key="my key"
value="my value"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key" "$value"

expected="$value"

if result="$(dm_store__get "$key")"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - setting the key again overrides old value'

rm -f "$TEMP_STORE_FILE_PATH"

key="my key"
old_value="my old value"
new_value="my new value"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key" "$old_value"
dm_store__set "$key" "$new_value"

expected="$new_value"

if result="$(dm_store__get "$key")"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - setting the key multiple times wont create new entry'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key" '1'
dm_store__set "$key" '2'
dm_store__set "$key" '3'
dm_store__set "$key" '4'
dm_store__set "$key" '5'
dm_store__set "$key" '6'
dm_store__set "$key" '7'
dm_store__set "$key" '8'
dm_store__set "$key" '9'

expected='1'

if result="$(dm_tools__wc --lines < "$DM_STORE__RUNTIME__STORAGE_FILE")"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - multiline values can be stored 1'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"
value_1='line 1'
value_2='line 2'
value="$( \
  dm_tools__echo "$value_1"; \
  dm_tools__echo "$value_2"; \
)"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key" "$value"

expected='2'

if result="$(dm_store__get "$key" | dm_tools__wc --lines)"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

dm_store__test__valid_case 'store - multiline values can be stored 2'

expected="$value_1"

if result="$(dm_store__get "$key" | dm_tools__sed --expression '1q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

dm_store__test__valid_case 'store - multiline values can be stored 3'

expected="$value_2"

if result="$(dm_store__get "$key" | dm_tools__sed --expression '2q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - even multiline keys can be used 1'

rm -f "$TEMP_STORE_FILE_PATH"

key="$( \
  dm_tools__echo 'key line 1'; \
  dm_tools__echo 'key line 2'; \
)"
value_1='line 1'
value_2='line 2'
value="$( \
  dm_tools__echo "$value_1"; \
  dm_tools__echo "$value_2"; \
)"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key" "$value"

expected='2'

if result="$(dm_store__get "$key" | dm_tools__wc --lines)"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - even multiline keys can be used 2'

expected="$value_1"

if result="$(dm_store__get "$key" | dm_tools__sed --expression '1q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - even multiline keys can be used 3'

expected="$value_2"

if result="$(dm_store__get "$key" | dm_tools__sed --expression '2q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - keys can be listed 1'

rm -f "$TEMP_STORE_FILE_PATH"

key_1="key_1"
key_2="key_2"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key_1" 'value'
dm_store__set "$key_2" 'value'

expected='2'

if result="$(dm_store__keys | dm_tools__wc --lines)"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - keys can be listed 2'

expected="$key_1"

if result="$(dm_store__keys | dm_tools__sed --expression '1q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - keys can be listed 3'

expected="$key_2"

if result="$(dm_store__keys | dm_tools__sed --expression '2q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - entries can be listed 1'

rm -f "$TEMP_STORE_FILE_PATH"

key_1="key_1"
key_2="key_2"
value_1="value_1"
value_2="value_2"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key_1" "$value_1"
dm_store__set "$key_2" "$value_2"

expected='2'

if result="$(dm_store__list | dm_tools__wc --lines)"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - entries can be listed 2'

expected="'${key_1}': '${value_1}'"

if result="$(dm_store__list | dm_tools__sed --expression '1q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - entries can be listed 3'

expected="'${key_2}': '${value_2}'"

if result="$(dm_store__list | dm_tools__sed --expression '2q;d')"
then
  dm_store__test__assert_equal "$expected" "$result"
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - entry can be deleted by key'

rm -f "$TEMP_STORE_FILE_PATH"

key="key"

dm_store__init "$TEMP_STORE_FILE_PATH"
dm_store__set "$key" 'value'

if dm_store__delete "$key"
then
  if dm_store__get "$key"
  then
    # Deleted key should not be retrievable.
    dm_store__test__test_case_failed '0'
  else
    dm_store__test__test_case_passed
  fi
else
  status="$?"
  dm_store__test__test_case_failed "$status"
fi

#==============================================================================
dm_store__test__valid_case 'store - nonexistent key cannot be retrieved'

rm -f "$TEMP_STORE_FILE_PATH"

dm_store__init "$TEMP_STORE_FILE_PATH"

if dm_store__get "invalid-key"
then
  # Invalid key should not be retrievable.
  dm_store__test__test_case_failed '0'
else
  dm_store__test__test_case_passed
fi

#==============================================================================
dm_store__test__valid_case 'store - empty store - keys cannot be listed'

rm -f "$TEMP_STORE_FILE_PATH"

dm_store__init "$TEMP_STORE_FILE_PATH"

if dm_store__keys
then
  # Invalid key should not be retrievable.
  dm_store__test__test_case_failed '0'
else
  dm_store__test__test_case_passed
fi

#==============================================================================
dm_store__test__valid_case 'store - empty store - entries cannot be listed'

rm -f "$TEMP_STORE_FILE_PATH"

dm_store__init "$TEMP_STORE_FILE_PATH"

if dm_store__list
then
  # Invalid key should not be retrievable.
  dm_store__test__test_case_failed '0'
else
  dm_store__test__test_case_passed
fi

#==============================================================================
# CLEANUP
#==============================================================================

rm -f "$TEMP_STORE_FILE_PATH"
