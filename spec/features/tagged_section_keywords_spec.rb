require 'spec_helper'

describe 'TaggedSectionKeywords' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /tagged_section_keywords' do
    before { visit tagged_section_keywords_path }
    specify 'an index name is present' do
      expect(page).to have_content('Tagged Section Keywords')
    end
  end
end
