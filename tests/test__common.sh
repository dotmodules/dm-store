printf '%s' "${DIM}"
printf '%s\n' \
  'Here we are testing the actual testing tools for both success and failure '
printf '%s\n' \
  'cases. That means here you will see red error messages but those are only '
printf '%s\n' \
  'for validating the testing assertion functions by eye. As posix_adapter is a '
printf '%s\n' \
  'fundamental tool for every further posix project, posix-test cannot be used here '
printf '%s\n' \
  'because it is based on posix_adapter too. So posix_adapter has to use a very minimal '
printf '%s\n' \
  'but also hard coded test suite. This initial tests somewhat make sure that '
printf '%s' \
  'this custom test suite is actually working as intended.'
printf '%s\n' "${RESET}"

printf '%s' '-------------------------------------------------------'
printf '%s\n' '-----------------------------'

#==============================================================================
# ASSERT EQUAL
#==============================================================================

# Here we are testing if the assertion function produces a success result if we
# compare two identical strings.
posix_store__test__valid_case 'common - assert_equal success test'
posix_store__test__assert_equal '42' '42'

# In this case we are forcing out an assertion failure by providing two
# different strings. The assertion should fail, and an appropriate error
# message should be printed out that will be captured by the tooling here. The
# assertion test is executed inside a subshell to capture its outputs and to be
# able to survive the exit call.
POSIX_STORE__TEST__SUPPRESS_RESULT_PRINTOUT='1'
posix_store__test__error_case 'common - assert_equal failure printout test'
if result="$(posix_store__test__assert_equal '42' '43')"
then
  _posix_store__test__test_case_failed
  printf '%s\n' 'Test case was expected to fail..'
else
  _posix_store__test__test_case_succeeded
  printf '%s\n' "$result" | sed "s/^/${DIM}captured output | ${RESET}/"
fi
POSIX_STORE__TEST__SUPPRESS_RESULT_PRINTOUT='0'

#==============================================================================
# TEST CASE FAILED
#==============================================================================

# This test case reporting fuction should be used if the tool exits an
# unexpected error status. In this case the test case will be marked as failed,
# and an appropriate error should be printed. As this function will make the
# execution to fail regardless of the input, we are only testing the error case
# here.
POSIX_STORE__TEST__SUPPRESS_RESULT_PRINTOUT='1'
posix_store__test__error_case 'common - test_case_failed failure printout test'
if result="$(posix_store__test__test_case_failed '42')"
then
  _posix_store__test__test_case_failed
  printf '%s\n' 'Test case was expected to fail..'
else
  _posix_store__test__test_case_succeeded
  printf '%s\n' "$result" | sed "s/^/${DIM}captured output | ${RESET}/"
fi

#==============================================================================
# FINISH
#==============================================================================

# After this test file we want to have the standard test result printout
# behavior, so we are setting back the global variable to its default value.
#shellcheck disable=SC2034
POSIX_STORE__TEST__SUPPRESS_RESULT_PRINTOUT='0'
