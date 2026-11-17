require 'rails_helper'

describe DownloadsHelper, type: :helper do

  context '#download_expires_tag' do
    specify 'nil download' do
      expect(helper.download_expires_tag(nil)).to be_nil
    end

    specify 'future expiry reads as "in ..."' do
      download = Download.new(expires: 3.days.from_now)
      expect(helper.download_expires_tag(download)).to eq('in 3 days')
    end

    specify 'past expiry reads as "... ago"' do
      download = Download.new(expires: 3.days.ago)
      expect(helper.download_expires_tag(download)).to eq('3 days ago')
    end
  end

end
