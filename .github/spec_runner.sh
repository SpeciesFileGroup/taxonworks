#!/bin/bash
set -e

# Runs worker TEST_WORKER's share of the specs (0 .. TEST_WORKERS - 1).
#
# parallel_tests splits the spec files into TEST_WORKERS groups by the
# per-file runtimes in .github/spec_runtimes.log: largest file first, each
# into the currently lightest group. Files missing from the log count as the
# average, so new specs don't need a log update. Every worker computes the
# same split from the same log and runs only its own group.
#
# Each worker also records its files' runtimes to tmp/spec_runtimes_N.log.
# The build workflow uploads them, and the monthly refresh-spec-runtimes
# workflow turns them into a pull request that updates
# .github/spec_runtimes.log (see .github/refresh_spec_runtimes.rb).

RUNTIME_LOG=".github/spec_runtimes.log"
RECORDED_RUNTIMES="tmp/spec_runtimes_$TEST_WORKER.log"

report_cleanup() {
  END_TIME=$(date +%s)

  echo "[TEST_WORKER=$TEST_WORKER Runtime] $[$END_TIME - $START_TIME]"
  [ ! -f public/assets/.sprockets-manifest-*.json ] || rm public/assets/.sprockets-manifest-*.json
}

START_TIME=$(date +%s)
trap 'report_cleanup' ERR

# --verbose prints the rspec command with this worker's spec files, so a
# worker's run can be reproduced locally.
# Argument order matters: parallel_rspec options, then `--` and rspec
# options, then `--` and the files; with a single `--` everything after it
# is taken as files.
bundle exec parallel_rspec \
  -n "$TEST_WORKERS" \
  --only-group $((TEST_WORKER + 1)) \
  --group-by runtime \
  --runtime-log "$RUNTIME_LOG" \
  --allowed-missing 100 \
  --verbose \
  -- \
  --force-color \
  --format progress \
  --format ParallelTests::RSpec::RuntimeLogger --out "$RECORDED_RUNTIMES" \
  -- \
  spec

report_cleanup
