require 'spec_helper'

describe 'BiocurationClassifications', base_class:  BiocurationClassification do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /biocuration_classifications' do
    before { 
      sign_in_valid_user_and_select_project 
      visit biocuration_classifications_path }
    specify 'an index name is present' do
      expect(page).to have_content('Biocuration Classifications')
    end
  end
end
