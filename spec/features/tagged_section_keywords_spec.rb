require 'spec_helper'

describe "TaggedSectionKeywords" do
  describe "GET /tagged_section_keywords" do
    before { visit tagged_section_keywords_path }
    specify 'an index name is present' do
      expect(page).to have_content('Tagged Section Keywords')
    end
  end
end
