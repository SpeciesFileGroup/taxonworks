require 'rails_helper'

describe 'DataAttributes' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { data_attributes_path }
    let(:page_index_name) { 'Data Attributes' }
  end

  describe 'GET /data_attributes' do
    before { 
      sign_in_user_and_select_project 
      visit data_attributes_path }
    specify 'an index name is present' do
      expect(page).to have_content('Data Attributes')
    end
  end
end
