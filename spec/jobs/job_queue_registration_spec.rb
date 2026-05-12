require 'rails_helper'

RSpec.describe 'Job queue registration' do
  # Jobs intentionally kept in app/jobs but not run in production.
  PRODUCTION_EXCLUDED_JOBS = %w[
    bibtex_create_download_job.rb
  ].freeze

  let(:exe_queues) do
    script = Rails.root.join('exe/delayed_job').read
    script.match(/QUEUE=([\w,]+)/)[1].split(',').to_set
  end

  let(:job_queues) do
    Dir.glob(Rails.root.join('app/jobs/*.rb')).filter_map do |path|
      next if PRODUCTION_EXCLUDED_JOBS.include?(File.basename(path))
      match = File.read(path).match(/queue_as\s+[:"'](\w+)/)
      { file: File.basename(path), queue: match[1] } if match
    end
  end

  specify 'all job queues are listed in exe/delayed_job' do
    unregistered = job_queues.reject { |j| exe_queues.include?(j[:queue]) }
    message = unregistered.map { |j| "  #{j[:file]} uses queue '#{j[:queue]}'" }.join("\n")
    expect(unregistered).to be_empty,
      "Job queues missing from exe/delayed_job QUEUE= line:\n#{message}"
  end
end
