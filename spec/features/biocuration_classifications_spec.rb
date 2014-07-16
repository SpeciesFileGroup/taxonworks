require 'rails_helper'

describe 'BiocurationClassifications' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { biocuration_classifications_path }
    let(:page_index_name) { 'Biocuration Classifications' }
  end

  describe 'GET /biocuration_classifications' do
    before { 
      sign_in_valid_user_and_select_project 
      visit biocuration_classifications_path }
    specify 'an index name is present' do
      expect(page).to have_content('Biocuration Classifications')
    end
  end
end
