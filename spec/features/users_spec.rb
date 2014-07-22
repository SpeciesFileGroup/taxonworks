require 'rails_helper'

describe 'Users' do
  subject { page }

  describe 'GET /users' do
    context 'when administrator' do
      before {
        sign_in_administrator
        visit users_path 
      }
      it 'should list users' do
        subject.should have_selector('h1', text: 'Users')
        subject.should have_content("#{@user.email}")
      end
    end

    context 'when not an administrator' do
      before {sign_in_administrator}
      it 'should redirect to dashboard and provide a notice' 
    end
  end

  describe 'GET /users/:id' do

    context 'show my user data' do
      before {
        sign_in_user
        visit user_path(@user)
      }

      it 'should show my email' do
        subject.should have_content("#{@user.email}")
      end
    end




    context 'when editing self' do
      before {
        sign_in_user
        visit edit_user_path(@user)
      }

      it 'should let user edit their account information' do
        txt = "Edit user #{@user.id}"
        subject.should have_selector('h1', txt)
        subject.should have_title("#{txt} | TaxonWorks")
        fill_in 'Email', with: 'edit_user_modified@example.com'
        fill_in 'Password', with: '1234ZZZ!'
        fill_in 'Password confirmation', with: '1234ZZZ!'
        click_button 'Update User'
        subject.should have_selector('.alert--success', 'Your changes have been saved.')
      end
    end

    context 'when editing someone else' do
      context 'and logged in as administrator' do
        before {
          sign_in_administrator
          visit edit_user_path(@user)
        }
        it 'should render' do
        end
      end

      context 'and not logged in as administrator' do
        it 'should redirect to dashboard and provide a notice'
      end

      context 'and logged in as a project_administrator' do
        before  {
        }
        it 'should redirect to dashboard and provide a notice'
      end
    end
  end

end
