require 'spec_helper'

describe 'Tags', base_class: Tag do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /tags' do
    before { visit tags_path }
    specify 'an index name is present' do
      expect(page).to have_content('Tags')
    end
  end
end


