require 'spec_helper'

describe 'Contents', base_class: Content do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /contents' do
    before { visit contents_path }
    specify 'an index name is present' do
      expect(page).to have_content('Contents')
    end
  end
end
