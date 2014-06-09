require 'spec_helper'

describe 'Repositories' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /repositories' do
    before { visit repositories_path }
    specify 'an index name is present' do
      expect(page).to have_content('Repositories')
    end
  end
end


