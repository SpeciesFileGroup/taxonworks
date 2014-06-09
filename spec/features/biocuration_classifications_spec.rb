require 'spec_helper'

describe 'BiocurationClassifications' do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /biocuration_classifications' do
    before { visit biocuration_classifications_path }
    specify 'an index name is present' do
      expect(page).to have_content('Biocuration Classifications')
    end
  end
end
