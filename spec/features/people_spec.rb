require 'spec_helper'

describe 'People' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /people' do
    before { visit people_path }
    specify 'an index name is present' do
      expect(page).to have_content('People')
    end
  end
end

