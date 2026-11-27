require 'rails_helper'

describe Vendor::Gnfinder::Client, type: :model do
  let(:response) { double(body: { metadata: {}, names: [] }.to_json) }

  specify '.finder is a Vendor::Gnfinder::Client' do
    expect(Vendor::Gnfinder.finder).to be_a(Vendor::Gnfinder::Client)
  end

  # Checks the request the gem actually sends, so a gem change that stops
  # using the rebuilt connection fails here.
  specify 'requests limit the wait to connect and keep the gem\'s options' do
    expect(RestClient::Request).to receive(:execute).with(
      hash_including(
        method: :post,
        url: 'https://finder.globalnames.org/api/v1/find',
        open_timeout: Vendor::Gnfinder::Client::OPEN_TIMEOUT,
        read_timeout: 60
      )
    ).and_return(response)

    Vendor::Gnfinder.finder.find_names('Aus bus')
  end
end
