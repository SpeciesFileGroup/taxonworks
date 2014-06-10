require 'spec_helper'

describe 'LoanItems', base_class: LoanItem do

  it_behaves_like 'a_login_required_and_project_selected_controller'

  describe 'GET /loan_items' do
    before {
      sign_in_valid_user_and_select_project 
      visit loan_items_path }
    specify 'an index name is present' do
      expect(page).to have_content('Loan Items')
    end
  end
end
