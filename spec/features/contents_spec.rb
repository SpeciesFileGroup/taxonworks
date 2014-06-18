require 'spec_helper'

describe 'Contents' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { contents_path }
    let(:page_index_name) { 'Contents' }
  end

  describe 'GET /contents' do
    before { 
      sign_in_user_and_select_project 
      visit contents_path }
    specify 'an index name is present' do
      expect(page).to have_content('Contents')
    end
  end
end
