require 'vcr'

VCR.configure do |c|
  c.default_cassette_options = { re_record_interval: ENV['CI'] ? 1.week : 1.day } # Lets tolerate the penalty of querying external APIs once a day for now.
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
end
