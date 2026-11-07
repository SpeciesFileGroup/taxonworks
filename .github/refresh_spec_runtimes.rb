#!/usr/bin/env ruby
# Rewrites .github/spec_runtimes.log, the per-file runtimes that
# .github/spec_runner.sh uses to split the specs among the CI workers.
#
# Each build worker uploads the runtimes of the files it ran as a
# `spec-runtimes-<worker>` artifact. This takes the most recent successful
# development builds that have all of them, and writes each spec file's
# median runtime across those builds. The median smooths out runner speed,
# which varies a lot between jobs.
#
# Run from anywhere; needs `gh` with read access to the repository's
# actions. Run by the monthly refresh-spec-runtimes workflow, or by hand:
#
#   ruby .github/refresh_spec_runtimes.rb
#
# Environment (optional):
#   GITHUB_REPOSITORY   default SpeciesFileGroup/taxonworks
#   SPEC_RUNTIME_BUILDS number of builds to take the median over, default 5
#   TEST_WORKERS        artifacts expected per build, default 4

require 'json'
require 'open3'
require 'tmpdir'

REPOSITORY = ENV.fetch('GITHUB_REPOSITORY', 'SpeciesFileGroup/taxonworks')
BUILDS = Integer(ENV.fetch('SPEC_RUNTIME_BUILDS', '5'))
WORKERS = Integer(ENV.fetch('TEST_WORKERS', '4'))
CANDIDATE_BUILDS = 30

ROOT = File.expand_path('..', __dir__)
RUNTIME_LOG = File.join(ROOT, '.github', 'spec_runtimes.log')

def gh(*args)
  output, error, status = Open3.capture3('gh', *args)
  [status.success?, output, error]
end

def median(values)
  sorted = values.sort
  middle = sorted.size / 2
  sorted.size.odd? ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2.0
end

# @return [Hash{String => Float}, nil] spec file => seconds, nil unless every
#   worker's artifact is present
def build_runtimes(run_id)
  Dir.mktmpdir do |directory|
    ok, _, _ = gh('run', 'download', run_id.to_s, '-R', REPOSITORY,
      '--pattern', 'spec-runtimes-*', '-D', directory)
    return nil if !ok

    logs = Dir.glob(File.join(directory, '**', 'spec_runtimes_*.log'))
    return nil if logs.size != WORKERS

    runtimes = {}
    logs.each do |log|
      File.foreach(log) do |line|
        file, seconds = line.strip.split(':', 2)
        seconds = Float(seconds, exception: false) if seconds
        runtimes[file] = seconds if file && seconds
      end
    end
    runtimes
  end
end

ok, output, error = gh('run', 'list', '-R', REPOSITORY,
  '--workflow', 'build.yml', '--branch', 'development', '--status', 'success',
  '--limit', CANDIDATE_BUILDS.to_s, '--json', 'databaseId,event')
abort("gh run list failed: #{error}") if !ok

run_ids = JSON.parse(output)
  .select { |r| %w{push schedule}.include?(r['event']) }
  .map { |r| r['databaseId'] }

builds = []
run_ids.each do |run_id|
  break if builds.size == BUILDS

  runtimes = build_runtimes(run_id)
  if runtimes.nil?
    warn "build #{run_id}: no complete set of spec-runtimes artifacts, skipped"
    next
  end
  warn "build #{run_id}: #{runtimes.size} spec files"
  builds << runtimes
end

abort('No build with spec-runtimes artifacts found; log unchanged') if builds.empty?
warn "Only #{builds.size} of #{BUILDS} builds found" if builds.size < BUILDS

# Only files that still exist; files with no runtime count as the average
# in parallel_tests.
spec_files = Dir.chdir(ROOT) { Dir.glob('spec/**/*_spec.rb') }

medians = spec_files.filter_map do |file|
  values = builds.filter_map { |runtimes| runtimes[file] }
  [file, median(values)] if values.any?
end

File.open(RUNTIME_LOG, 'w') do |log|
  medians.sort_by { |file, seconds| [-seconds, file] }.each do |file, seconds|
    log.puts format('%s:%.2f', file, seconds)
  end
end

warn "Wrote #{medians.size} of #{spec_files.size} spec files from " \
  "#{builds.size} builds to #{RUNTIME_LOG}"
