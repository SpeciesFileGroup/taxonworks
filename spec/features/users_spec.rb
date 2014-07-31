require 'rails_helper'

describe 'Users' do
  #  subject { page }

  # All users must sign in
  # When a worker signs in, what does he see, what can he do?  dashboard, what links?
  # When a project administrator signs in, what does he see, what can do?
  # When an administrator signs in, what does he see, what can he do?


  describe 'GET /users' do    # this is users/index page? Only signed in admins can see it
    context 'when administrator' do
      before {
        sign_in_administrator
        visit users_path
      }
      it 'should list users' do
        expect(page).to have_selector('h1', text: 'Users')
        expect(page).to have_content("#{@user.email}")
        expect(page).to have_link('Administration')
      end
    end

    context 'when not an administrator' do   # how would a non administrator get to this page?
      before { sign_in_administrator }
      it 'should redirect to dashboard and provide a notice'
    end
  end

  describe 'GET /users/:id' do    # this is user show

    context 'when logged in on dashboard' do
      before {
        sign_in_user
        visit user_path(@user)
      }

    end


    # it 'should show my basic attributes' do
    #   expect(page).to have_link("Edit user information", href: user_information_path)
    #   expect(page).to have_link("View my statistics", href: user_statistics_path)
    #   # what projects I belong, currently logged into projects,
    # end


    context 'when editing self' do         # this is either edit oneself or an admin editing someone else
      before {
        sign_in_user
        visit edit_user_path(@user)
      }

      it 'should let user edit their account information' do
        txt = "Edit user #{@user.id}"
        expect(page).to have_selector('h1', txt)
        expect(page).to have_title("#{txt} | TaxonWorks")
        fill_in 'Email', with: 'edit_user_modified@example.com'
        fill_in 'Password', with: '1234ZZZ!'
        fill_in 'Password confirmation', with: '1234ZZZ!'
        click_button 'Update User'

        expect(page).to have_css('p.alert.alert--success', 'Changes to your account information have been saved.')


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
        before {
        }
        it 'should redirect to dashboard and provide a notice'
      end
    end
  end
end
