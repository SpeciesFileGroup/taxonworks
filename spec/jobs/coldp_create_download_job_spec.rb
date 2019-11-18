require 'rails_helper'

RSpec.describe ColdpCreateDownloadJob, type: :job do
  subject (:job) { ColdpCreateDownloadJob.perform_later(nil, nil) }

  it "queues job in coldp_export queue" do
    expect { job }.to have_enqueued_job(ColdpCreateDownloadJob).with(nil).on_queue('coldp_export')
  end
end
