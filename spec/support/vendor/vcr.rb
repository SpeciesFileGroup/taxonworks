require 'vcr'

# Cassettes are committed, so specs don't depend on which CI worker's cache
# they land in. Only CI builds of the repository's own branches re-record
# them against the live services, weekly. PR builds (which, from a fork, get
# no secrets such as CROSSREF_EMAIL) and local runs replay the committed
# cassettes; delete one to record it fresh.
RE_RECORD_CASSETTES = ENV['CI'].present? &&
  ENV['GITHUB_EVENT_NAME'] != 'pull_request'

VCR.configure do |c|
  c.default_cassette_options = {
    re_record_interval: RE_RECORD_CASSETTES ? 1.week : nil
  }
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end
