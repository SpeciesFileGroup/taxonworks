# Pass an index_path like:
#
# it_behaves_like 'a_login_required_and_project_selected_controller' do 
#   let(:index_path) { projects_path }
#   let(:page_index_name) { 'Dashboard' }
# end
#
shared_examples 'a_login_required_and_project_selected_controller' do
  describe 'authorization' do
    describe "submitting request without sign_in redirects to root_path" do
      before { visit index_path  }
      specify { 
        expect(page).to have_button 'Sign in'
      }
    end

    describe "submitting a request with sign_in but no project redirects to dashboard" do
      before(:each) {
        sign_in_valid_user
        visit index_path 
      }
      specify { expect(page).to have_content 'Dashboard' }
    end

    describe "submitting a request with sign_in and project selected renders " do
      before(:each) {
        sign_in_valid_user
        select_a_project
        visit index_path 
      }
      specify { 
        expect(page).to have_content page_index_name 
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
    describe "submitting request without sign_in redirects to root_path" do
      before { visit index_path  }
      specify { 
        expect(page).to have_button 'Sign in'
      }
    end
  end

end

