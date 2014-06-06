require 'spec_helper'

describe "Contents" do
  describe "GET /contents" do
    before { visit contents_path }
    specify 'an index name is present' do
      expect(page).to have_content('Contents')
    end
  end
end
