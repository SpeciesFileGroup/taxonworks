require 'spec_helper'

describe "Peoples" do
  describe "GET /tags" do
    before { visit tags_path }
    specify 'an index name is present' do
      expect(page).to have_content('Tags')
    end
  end
end


