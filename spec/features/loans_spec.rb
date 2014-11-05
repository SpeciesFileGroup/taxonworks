require 'rails_helper'

describe 'Loans', :type => :feature do

  it_behaves_like 'a_login_required_and_project_selected_controller' do
    let(:index_path) { loans_path }
    let(:page_index_name) { 'Loans' }
  end

  context 'with some records created' do
    before {
      sign_in_user_and_select_project
      10.times { factory_girl_create_for_user_and_project(:valid_loan, @user, @project) }
    }

    describe 'GET /loans' do
      before { visit loans_path }
      specify 'an index name is present' do
        expect(page).to have_content('Loans')
      end
    end

    describe 'GET /loans/list' do
      before do
        visit list_loans_path
      end

      specify 'that it renders without error' do
        expect(page).to have_content 'Listing Loans'
      end
    end

    describe 'GET /loans/n' do
      before {
        visit loan_path(Loan.second) 
      }

      specify 'there is a "previous" link' do
        expect(page).to have_link('Previous')
      end

      specify 'there is a "next" link' do
        expect(page).to have_link('Next')
      end
    end
  end
end
