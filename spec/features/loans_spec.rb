require 'rails_helper'

describe 'Loans', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { loans_path }
    let(:page_index_name) { 'Loans' }
  end

  describe 'GET /loans' do
    before {
      sign_in_user_and_select_project
      visit loans_path }
    specify 'an index name is present' do
      expect(page).to have_content('Loans')
    end

  end

  describe 'GET /loans/list' do
    before do
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      # this is so that there are more than one page of loans
      30.times { FactoryGirl.create(:valid_loan) }
      visit '/loans/list'
    end

    specify 'that it renders without error' do
      expect(page).to have_content 'Listing Loans'
    end

  end

  describe 'GET /loans/n' do
    before {
      sign_in_user_and_select_project
      $user_id = 1; $project_id = 1
      3.times { FactoryGirl.create(:valid_loan) }
      all_loans = Loan.all.map(&:id)
      # there *may* be a better way to do this, but this version *does* work
      visit "/loans/#{all_loans[1]}"
    }

    specify 'there is a \'previous\' link' do
      expect(page).to have_link('Previous')
    end

    specify 'there is a \'next\' link' do
      expect(page).to have_link('Next')
    end

  end

end
