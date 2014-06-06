require 'spec_helper'

describe "PublicContents" do
  describe "GET /public_contents" do
    before { visit public_contents_path }
    specify 'an index name is present' do
      expect(page).to have_content('Public Contents')
    end
  end
end
