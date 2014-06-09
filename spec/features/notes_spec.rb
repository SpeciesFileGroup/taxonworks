require 'spec_helper'

describe 'Notes' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /Notes' do
    before { visit notes_path }
    specify 'an index name is present' do
      expect(page).to have_content('Notes')
    end
  end
end
