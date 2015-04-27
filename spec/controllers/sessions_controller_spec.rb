require 'rails_helper'

describe SessionsController, :type => :controller do
  
  describe "GET new" do
    it "renders the 'new' template" do
      get :new
      expect(response).to render_template("new")
    end
  end
  
  describe "POST create" do
    
    context "valid user" do
      let(:password) { '12345678abcd' }
      let(:email) { 'sessions@example.com' }
    
      context "when not flagged for password reset" do
        before { 
          User.create!(name: 'Test',
            email: email,
            password: password,
            password_confirmation: password,
            self_created: true)
        }
            
        it "signs in the user and redirects to root when password is valid" do
          post :create, { session: { email: email, password: password } }
          expect(controller.sessions_signed_in?).to be_truthy
          expect(response).to redirect_to root_path
        end
         
        it "does not sign in the user when the password is invalid" do
          post :create, { session: { email: email, password: 'invalid' } }
          expect(controller.sessions_signed_in?).to be_falsey
        end    
      end
      
      context "when flagged for password reset" do
        let!(:user) { 
          User.create!(name: 'Test',
            email: email,
            password: password,
            password_confirmation: password,
            self_created: true,
            is_flagged_for_password_reset: true)
        }
                
        it "renders password reset request and does not sign in the user when password is valid" do
          post :create, { session: { email: email, password: password } }
          expect(response).to render_template("request_password_reset")
          expect(assigns(:user)).to eq(user)
          expect(controller.sessions_signed_in?).to be_falsey
        end
        
        it "does not sign in the user when password is invalid" do
          post :create, { session: { email: email, password: 'invalid' } }
          expect(controller.sessions_signed_in?).to be_falsey
        end
      end
      
    end
    
    context "invalid user" do
      
      it "does not authorize access to the application" do
        post :create, { session: {email: 'invalid@example.com', password: 'invalid' } }
        expect(controller.sessions_signed_in?).to be_falsey
      end
    end

  end

  describe "DELETE destroy" do
    it "signs out the current user" do
      expect(controller).to receive(:sessions_sign_out)
      delete :destroy
      expect(response).to redirect_to root_path
    end
  end  
end