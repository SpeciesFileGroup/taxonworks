require 'rails_helper'

RSpec.describe ColdpCreateDownloadJob, type: :job, group: :col  do

  # !! See spec/lib/export/coldp_spec.rb

  it 'queues job in coldp_export queu' do
    expect { ColdpCreateDownloadJob.perform_later(nil, nil) }.to have_enqueued_job(ColdpCreateDownloadJob).with(nil).on_queue('coldp_export')
  end

  it 'sends notification on exception' do
    begin
      ColdpCreateDownloadJob.perform_now(nil, nil)
    rescue
    end
    expect(ActionMailer::Base.deliveries.last.body).to include('Backtrace')
  end

end
