#!/bin/bash
TEST_CMD="curl --max-time 5 --fail http://localhost:$2/api/v1/ping"

re='^[0-9]+$'
! [[ $1 =~ $re ]] && echo "Error: integer startup timeout seconds not supplied!" >&2 && exit 1
! [[ $2 =~ $re ]] && echo "Error: port not supplied" >&2 && exit 1

# Hit URL
$TEST_CMD -s && exit 0

# Hit failed. Starting up?
if [ ! -f "tmp/init_complete" ]; then
  # Startup delay
  while (( ${SECONDS} < $1 )) && ! $TEST_CMD -s > /dev/null 2>&1; do
    sleep $(( ${SECONDS} + 5 < $1 ? 5 : 1 ))
  done
fi

# Pass result of test
$TEST_CMD
