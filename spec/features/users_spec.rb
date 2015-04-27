require 'rails_helper'

describe 'Users' do

  # All users must sign in -- a user isn't a user until s/he signs in
  # When a worker signs in, what does he see, what can he do?  dashboard, what links?
  # When a project administrator signs in, what does he see, what can do?
  # When an administrator signs in, what does he see, what can he do?
  # # When an admin creates new user, how does he initialize user password?


  context 'when user is signed in' do # before user signs in, s/he is on /signin page
    context 'with unprivileged user' do  
      before {
        sign_in_user
        visit root_path
      }

      it 'on Dashboard, should have information and links' do
        expect(page).to have_content("#{@user.name}")
        expect(page).to have_link('Account')
        expect(page).to have_link('Sign out')
        expect(page).to_not have_link('Administration')
      end

      context 'in order to edit self' do
        before {
          click_link 'Account'
        }

        it 'should have information and links' do
          expect(page).to have_css('h1', @user.name)
          expect(page).to have_link('Edit')
        end

        context 'editing self' do
          before {
            click_link 'Edit'
          }

          it 'should have information and links' do
            # How to say what path this is edit_users_path(@user)?
            #   You can't really, you use a proxy, looking for content that is unique to that path
            # URI.parse(current_url).should == "users/#{@user}/edit"
            # expect(current_url).to eq "/users/#{@user}/edit"

            expect(page).to have_css('h1', 'Editing user')
            expect(page).to have_selector('label', 'Password confirmation')
            expect(page).to have_button('Update User') # where is submit button "Update User"?
          end

          it 'should let user edit all fields of their account information' do
            fill_in 'Name', with: 'Modified Name'
            fill_in 'Email', with: 'edit_user_modified@example.com'
            fill_in 'Password', with: '1234ZZZ!'
            fill_in 'Password confirmation', with: '1234ZZZ!'
            click_button 'Update User'

            expect(page).to have_css('p.alert.alert-success', 'Changes to your account information have been saved.')
          end

          before { visit edit_user_path(@user) } # click_link 'Edit account'

          it 'should let user edit only their email address' do
            fill_in 'Email', with: 'second_edit_user_modified@example.com'
            # fill_in 'Password', with: '1234ZZZ!'
            # fill_in 'Password confirmation', with: '1234ZZZ!'
            click_button 'Update User'

            expect(page).to have_css('p.alert.alert-success', 'Changes to your account information have been saved.')
          end

          before { visit edit_user_path(@user) } # click_link 'Edit account'

          it 'should let user edit their account information' do
            fill_in 'Email', with: 'third_edit_user_modified@example.com'
            fill_in 'Password', with: '1234ZZZ!'
            fill_in 'Password confirmation', with: nil
            click_button 'Update User'

            expect(page).to_not have_css('p.alert.alert-success', 'Changes to your account information have been saved.')
          end
        end
      end
    end

    context 'when user is administrator' do
      before {
        sign_in_administrator # not a member of a project
        visit root_path # Dashboard
      }

      it 'should have information and actions' do
        expect(page).to have_link('Administration')
        expect(page).to have_css('h1', 'Dashboard')
        # expect(page).to have_css('h2', 'Projects')
        # expect(page).to have_link('My Project')
      end

      before { click_link 'Administration' }

      it 'should have information and actions' do
        expect(page).to have_css('h1', 'Projects')
        expect(page).to have_css('a', 'New')   # todo @mjy why doesn't 'have_link' work here but right above expect(page).to have_link 'Administration' works?
        expect(page).to have_css('a', 'Projects overview')
        expect(page).to have_css('h1', 'Project Membership')
        expect(page).to have_css('a', 'Add a user to a project')
        expect(page).to have_css('h1', 'Users')
        expect(page).to have_css('a', 'New')    # todo @mjy Is there a way to say the page has two links called "New?"
        expect(page).to have_css('a', "Update a user's authorization")
      end

      before {
        visit users_path # users index
      }

      it 'should list users' do
        expect(page).to have_selector('h1', text: 'Users')
      end
    end


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

      context 'when not an administrator' do   # how would a non administrator get to this page? By entering the URL manually in the browser's address bar
        before { 
          sign_in_user
          visit users_path 
        }
        it 'should redirect to dashboard and provide a notice' do
          expect(page.current_path).to eq('/') # TODO: eq(dashboard_path) doesn't work and the fact that root is also dashboard#index is being assumed rather than tested
          expect(page).to have_content('Please sign in as an administrator.') 
        end
      end
    end

    describe 'GET /users/:id' do    # this is user show

      context 'when logged in on dashboard' do
        before {
          sign_in_user
          visit user_path(@user)
        }

        describe 'basic attributes contents' do
          it 'shows *', skip: 'Add specs for missing attributes' # TODO: Finish the spec
      
          describe 'API access token' do
            let(:token_label) { 'API access token' }
        
            context 'when there is no token' do
              it 'doesn\'t show the API access token label' do
                expect(page).to_not have_content(token_label)
              end
            end
        
            context 'when there is a token' do
              before {
                @user.generate_api_access_token
                @user.save       
                visit user_path(@user)
              }
          
              it 'shows the API access token label' do
                expect(page).to have_content(token_label)
              end
          
              it 'shows the API access token string' do
                expect(page).to have_content(@user.api_access_token)
              end
            end
          end
      
          it 'provides a link to edit the account' do
            expect(page).to have_link('Edit', href: edit_user_path(@user))
          end
          it 'provides a link to the user statistics page', skip: 'statistics page not implemented' do
            expect(page).to have_link('View my statistics', href: user_statistics_path)
            # what projects I belong, currently logged into projects,
          end
        end 
      end

      context 'when editing self' do         # this is either edit oneself or an admin editing someone else
        before {
          sign_in_user
          visit edit_user_path(@user)
        }
   
        it 'should let user edit their account information' do
          txt = "Editing user"
          expect(page).to have_selector('h1', txt)
          fill_in 'Email', with: 'edit_user_modified@example.com'
          fill_in 'Password', with: '1234ZZZ!'
          fill_in 'Password confirmation', with: '1234ZZZ!'
          click_button 'Update User'
   
          expect(page).to have_css('p.alert.alert-success', 'Changes to your account information have been saved.')
        end
      end

      context 'when editing someone else' do
        context 'and logged in as administrator' do
          before {
            sign_in_administrator
            visit edit_user_path(@user)
          }
          it 'should render'
        end

        context 'and not logged in as administrator' do  # where is this prompt?
          it 'should redirect to dashboard and provide a notice'
        end

        context 'and logged in as a project_administrator' do        # where is this prompt?
          before {
          }
          it 'should redirect to dashboard and provide a notice'
        end
      end
    end
  end

  context 'when user is not signed in' do
    before(:all) { spin_up_project_and_users }
    before { visit root_path }
    
    feature 'forgotten password reset' do
      before { click_link 'forgot password?' }
      
      scenario 'invalid email' do
        fill_in 'Email', with: 'invalid@example.com'
        click_button 'Send e-mail'
        
        expect(page).to have_text('The supplied e-mail does not belong to a registered user')
      end
      
      scenario 'empty email' do
        click_button 'Send e-mail'
        
        expect(page).to have_text('No e-mail was given')
      end
      
      context 'valid email' do
        before do
          fill_in 'Email', with: 'user@example.com'
          click_button 'Send e-mail'
        end
        
        scenario 'request password reset' do
          password = '12345678abcd'
          expect(page).to have_content('Password reset request sent!')
          mail = ActionMailer::Base.deliveries.last
          path = mail.body.match(/http(s)?:\/\/[^\/]+(?<path>\S+)/)['path']
          visit path
          # current error is 'Token not present or expired.' 
          fill_in 'Password', with: password
          fill_in 'Password confirmation', with: password
          click_button 'Change password'
          expect(page).to have_content('Password successfuly changed')
          fill_in 'Email', with: 'user@example.com'
          fill_in 'Password', with: password
          click_button 'Sign in'
          expect(page).to have_content('Dashboard')
          visit path
          expect(page).to have_content('The token is not valid or has been expired.')
        end
      end
    end

    feature 'flagged for password reset', js: true do
      before { 
          User.create!(name: 'Test',
            email: 'flagged@example.com',
            password: '12345678',
            password_confirmation: '12345678',
            self_created: true,
            is_flagged_for_password_reset: true)
      }
      scenario 'requesting password reset from sign in process' do
        visit root_path
        fill_in 'Email', with: 'flagged@example.com'
        fill_in 'Password', with: '12345678'
        click_button 'Sign in'
        click_button 'Send e-mail'
        expect(page).to have_content('Password reset request sent!')
      end
    end
  end
end
