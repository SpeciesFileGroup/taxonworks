require 'spec_helper'

describe 'LoanItems' do

  it_behaves_like 'a_login_required_and_project_selected_controller' do 
    let(:index_path) { loan_items_path }
    let(:page_index_name) { 'Loan Items' }
  end 

  describe 'GET /loan_items' do
    before {
      sign_in_user_and_select_project 
      visit loan_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Loan Items')
    end
  end
end
