#!/bin/bash
set -e

PARAMS_FILE=".github/spec_runner.rc"
for ((i=0; i<TEST_WORKERS; i++))
do
  TEST_WORKERS_PROPORTIONS[i]=1/$TEST_WORKERS
done

# Override array above to change specs distribution amongst workers (if params file exists)
[ -f $PARAMS_FILE ] && source $PARAMS_FILE || true

SPEC_FILES=$(find spec -type f -name "*_spec.rb" | sort)
SPEC_COUNT=$[$(echo $SPEC_FILES | wc -w)]

BEGIN_INDEX=1

for ((i=0; i<TEST_WORKERS; i++))
do
  END_INDEX=$[$BEGIN_INDEX + $SPEC_COUNT * ${TEST_WORKERS_PROPORTIONS[i]} - 1]

  SPECS_TO_RUN[i]=$(echo $SPEC_FILES | cut -d " " -f $BEGIN_INDEX-$END_INDEX)

  BEGIN_INDEX=$[$END_INDEX + 1]
done

# Charge last worker with any remaining specs
 [ "$BEGIN_INDEX" -gt "$SPEC_COUNT" ] || \
 SPECS_TO_RUN[(($TEST_WORKERS-1))]+=" $(echo $SPEC_FILES | cut -d " " -f $BEGIN_INDEX-$SPEC_COUNT)"

report_cleanup() {
  END_TIME=$(date +%s)

  echo "[TEST_WORKER=$TEST_WORKER Runtime] $[$END_TIME - $START_TIME]"
  echo "[TEST_WORKER=$TEST_WORKER Proportion] $[$(echo ${SPECS_TO_RUN[$TEST_WORKER]} | wc -w)]/$SPEC_COUNT"
  [ ! -f public/assets/.sprockets-manifest-*.json ] || rm public/assets/.sprockets-manifest-*.json
}

START_TIME=$(date +%s)
trap 'report_cleanup' ERR

echo "[TEST_WORKER=$TEST_WORKER specs set] ${SPECS_TO_RUN[$TEST_WORKER]}"
bundle exec rspec --force-color ${SPECS_TO_RUN[$TEST_WORKER]}

report_cleanup
