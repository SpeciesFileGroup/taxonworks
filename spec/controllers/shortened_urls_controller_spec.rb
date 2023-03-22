require 'rails_helper'

RSpec.describe Shortener::ShortenedUrlsController, type: :controller do
  let(:path) { '/spec/files/images/RubuRailsExistance.png' }
  let(:base_path) { 'spec/files/images'}

  describe '#show' do
    it 'redirects to stored file' do
      url = Shortener::ShortenedUrl.generate(path)
      expect(get(:show, params: { id: url.unique_key })).to redirect_to(path)
    end

    it 'redirects to shortener root when token is invalid' do
      expect(get(:show, params: { id: 'INVALID_TOKEN' })).to redirect_to('/s')
    end 

    it 'redirects even if file no longer exists' do
      temp_path = nil
      url = Tempfile.create('shortener_deleted.png', base_path) do |file|
        temp_path = "#{base_path}/#{File.basename(file)}"
        Shortener::ShortenedUrl.generate(temp_path)
      end
      expect(get(:show, params: { id: url.unique_key })).to redirect_to("/" + temp_path)
    end
  end
    
end
