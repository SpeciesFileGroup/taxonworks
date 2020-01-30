require 'rails_helper'

RSpec.describe ColdpCreateDownloadJob, type: :job do

  it "queues job in coldp_export queue" do
    expect { ColdpCreateDownloadJob.perform_later(nil, nil) }.to have_enqueued_job(ColdpCreateDownloadJob).with(nil).on_queue('coldp_export')
  end

  it "sends notification on exception" do
    begin
      ColdpCreateDownloadJob.perform_now(nil, nil)
    rescue
    end
    expect(ActionMailer::Base.deliveries.last.body).to include("Backtrace")
  end
end
