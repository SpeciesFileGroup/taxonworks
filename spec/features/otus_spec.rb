require 'spec_helper'
describe "Otus" do
  describe 'authorization' do
    
    describe "submitting request without sign_in redirects to root_path" do
      before { visit otus_path }
      specify { expect(page).to have_button 'Sign in' }
    end

    describe "submitting a request with sign_in but no project redirects to dashboard" do
     before(:each) {
       sign_in_valid_user
       visit otus_path 
     }
     specify { expect(page).to have_content 'Dashboard' }
    end

    describe "submitting a request with sign_in and project selected renders " do
      before(:each) {
        sign_in_valid_user
        select_a_project
        visit otus_path 
      }
      specify { expect(page).to have_content 'Otus' }
    end
  end
end
