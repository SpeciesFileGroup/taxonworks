require 'spec_helper'

describe 'Namespaces' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /Namespaces' do
    before { visit namespaces_path }
    specify 'an index name is present' do
      expect(page).to have_content('Namespaces')
    end
  end
end








