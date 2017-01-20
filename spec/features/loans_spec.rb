require 'rails_helper'

describe 'Loans', type: :feature do

  let(:index_path) { loans_path }
  let(:page_title) { 'Loans' }

  it_behaves_like 'a_login_required_and_project_selected_controller'

  context 'signed in a user with some records created' do
    before {
      sign_in_user_and_select_project
    }
    context 'with some records created' do 
      before {
        10.times { factory_girl_create_for_user_and_project(:valid_loan, @user, @project) }
      }

      context 'GET /loans' do
        before {
          visit index_path
        }

        it_behaves_like 'a_data_model_with_standard_index'
      end

      describe 'GET /loans/list' do
        before do
          visit list_loans_path
        end

        it_behaves_like 'a_data_model_with_standard_list_and_records_created'
      end

      describe 'GET /loans/n' do
        before {
          visit loan_path(Loan.second)
        }

        it_behaves_like 'a_data_model_with_standard_show'
      end
    end
  end
end
