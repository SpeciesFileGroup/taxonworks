require 'spec_helper'

describe "Otus" do

  describe 'authorization' do

  #   before { sign_in_user, no_capybara: true }

    describe "submitting request without sign_in redirects to root_path" do
      before { get otus_path }
      specify { expect(response).to redirect_to(root_path) }
    end

    describe "submitting a request with sign_in but no project redirects to dashboard" do
     before(:each) {
       sign_in_user
       get otus_path 
     }
     specify { expect(response).to redirect_to(dashboard_path) }
    end

    describe "submitting a request with sign_in and project selected renders " do
      before(:each) {
        sign_in
        get otus_path 
      }
      specify { expect(response).to render_template(:index) }
    end



  end

end
