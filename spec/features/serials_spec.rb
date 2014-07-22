require 'rails_helper'

describe 'Serials' do

  it_behaves_like 'a_login_required_controller' do 
    let(:index_path) { serials_path }
    let(:page_index_name) { 'Serials' }
  end 

  describe 'GET /serials' do
    before { 
      sign_in_user_and_select_project 
      visit serials_path }
    specify 'an index name is present' do
      expect(page).to have_content('Serials')
    end
  end
end

