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
        sign_in_user
        visit index_path 
      }
      specify { expect(page).to have_content 'Dashboard' }
    end

    describe "submitting a request with sign_in and project selected renders " do
      before(:each) {
        sign_in_user_and_select_project
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

# All(?) actions must require administration
shared_examples 'an_administrator_login_required_controller' do
  describe 'authorization' do
    describe "submitting request without sign_in redirects to root_path" do
      before { visit index_path  }
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

    describe 'submitting request as administrator renders the index' do
      before { 
        sign_in_administrator
        visit(index_path)
      }

      specify 'foo' do
         expect(page).to have_text('Administration')
      end
    end
  end
end

