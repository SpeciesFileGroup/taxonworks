require 'spec_helper'

describe 'Citations', base_class: Citation do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /citations' do
    before { visit citations_path }
    specify 'an index name is present' do
      expect(page).to have_content('Citations')
    end
  end
end
