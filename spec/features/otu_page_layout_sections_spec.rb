require 'spec_helper'

describe 'OtuPageLayoutSections', base_class: OtuPageLayoutSection do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /otu_page_layout_sections' do
    before { visit otu_page_layout_sections_path }
    specify 'an index name is present' do
      expect(page).to have_content('Otu Page Layout Sections')
    end
  end
end
