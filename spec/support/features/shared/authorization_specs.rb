# Pass an index_path like:
#
# it_behaves_like 'a_login_required_and_project_selected_controller' do 
#   let(:index_path) { projects_path }
#   let(:page_title) { 'Dashboard' }
# end
#
shared_examples 'a_login_required_and_project_selected_controller' do
  describe 'authorization' do
    describe 'submitting request without sign_in redirects to root_path' do
      before { visit index_path }
      specify {
        expect(page).to have_button 'Sign in'
      }
    end

    describe 'submitting a request with sign_in but no project redirects to dashboard' do
      before(:each) {
        sign_in_user
        visit index_path
      }
      specify {
        expect(page).to have_content 'Dashboard'
      }
    end

    describe 'submitting a request with sign_in and project selected renders ' do
      before(:each) {
        sign_in_user_and_select_project
        visit index_path
      }
      specify {
        expect(page).to have_content(page_title), "can not find '#{page_title}'"
      }
    end
  end
end

# Pass an index_path like:
#
#   it_behaves_like 'a_login_required_controller' do
#     let(:index_path) { hub_path }
#   end
# 
shared_examples 'a_login_required_controller' do
  describe 'authorization' do
    describe 'submitting request without sign_in redirects to root_path' do
      before { visit index_path } # index_path should be tests path
      specify {
        expect(page).to have_button 'Sign in'
      }
    end
  end
end

# All(?) actions must require administration
# Assumes an otherwise valid request
shared_examples 'an_administrator_login_required_controller' do
  describe 'authorization' do
    describe "submitting request without sign_in redirects to root_path" do
      before { visit index_path }
      specify {
        expect(page).to have_button 'Sign in'
      }
    end

    context 'submitting request as user redirects to root_path' do
      before {
        sign_in_user
        visit index_path
      }

      specify 'redirects to root_path' do
        expect(current_path).to eq(root_path)
      end

      specify 'no administration link is present' do
        expect(page).to_not have_link('Administration')
      end

    end

    describe 'submitting a valid request as administrator renders the index' do
      before {
        sign_in_administrator
        visit(index_path)
      }

      specify 'Page should have administrator link' do
        expect(page).to have_text('Administration')
      end
    end
  end
end


#
# it_behaves_like 'is_authorized_when_signed_in_as_administator' do 
#   let(:administrator) { @administrator }
#   let(:index_path) { your_path() }
# end
#
shared_examples 'is_authorized_when_signed_in_as_administator' do
  specify {
    paths.each do |path|
      visit path
      # stronger expectation here
      expect(page).to have_text('Administration')
    end
  } 
end 



# it_behaves_like 'is_not_authorized_when_signed_in_as_user' do 
#   let(:administrator) { @user }
#   let(:index_path) { your_path() }
# end
#
shared_examples 'is_not_authorized_when_signed_in_as_user' do
  specify {
    paths.each do |path|
      visit path
      # stronger expectation here
      expect(current_path).to eq(root_path)
    end
  } 
end 




