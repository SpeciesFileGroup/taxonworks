require 'rails_helper'

describe Shortener::ShortenerHelper, type: :helper do
  context 'shortener has some helpers' do
    let(:long_path) { '/spec/files/images/RubuRailsExistance.png' }
    let(:short_path) { short_url(long_path) }
    let(:token) {short_path.split('/').last}

    specify 'short_url set to 6 characters' do
      expect(short_path.split('/')[4].length).to eq(6)
    end

    specify 'short_url subdirectory is \'s\'' do
      expect(short_path.split('/')[3]).to eq('s')
    end

    specify 'retreving a long url' do
      url = ::Shortener::ShortenedUrl.fetch_with_token(token: token)
      expect(url[:url]).to eq(long_path)
    end
  end
end
