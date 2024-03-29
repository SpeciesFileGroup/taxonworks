require 'rails_helper'

# This spec was generated by rspec-rails when you ran the scaffold generator.
# It demonstrates how one might use RSpec to specify the controller code that
# was generated by Rails when you ran the scaffold generator.
#
# It assumes that the implementation code is generated by the rails scaffold
# generator.  If you are using any extension libraries to generate different
# controller code, this generated spec may or may not pass.
#
# It only uses APIs available in rails and/or rspec-rails.  There are a number
# of tools you can use to make these specs even more expressive, but we're
# sticking to rails and rspec-rails APIs to keep things simple and stable.
#
# Compared to earlier versions of this generator, there is very limited use of
# stubs and message expectations in this spec.  Stubs are only used when there
# is no simpler way to get a handle on the object needed for the example.
# Message expectations are only used when there is no simpler way to specify
# that an instance is receiving a specific message.

describe LoansController, type: :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Loan. As you add validations to Loan, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) { strip_housekeeping_attributes(FactoryBot.build(:valid_loan).attributes) }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # LoansController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET list' do
    it 'with no other parameters, assigns 20/page loans as @loans' do
      loan = Loan.create! valid_attributes
      get :list, params: {}, session: valid_session
      expect(assigns(:loans)).to include(loan)
    end

    it 'renders the list template' do
      get :list, params: {}, session: valid_session
      expect(response).to render_template('list')
    end
  end

  describe 'GET index' do
    it 'assigns all loans as @recent_objects' do
      loan = Loan.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects).to_a).to include(loan)
    end
  end

  describe 'GET show' do
    it 'assigns the requested loan as @loan' do
      loan = Loan.create! valid_attributes
      get :show, params: {id: loan.to_param}, session: valid_session
      expect(assigns(:loan)).to eq(loan)
    end
  end

  describe 'GET new' do
    it 'redirects to edit loan task' do
      get :new, params: {}, session: valid_session
      expect(response).to redirect_to(edit_loan_task_path)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested loan as @loan' do
      loan = Loan.create! valid_attributes
      get :edit, params: {id: loan.to_param}, session: valid_session
      expect(assigns(:loan)).to eq(loan)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new Loan' do
        expect {
          post :create, params: {loan: valid_attributes}, session: valid_session
        }.to change(Loan, :count).by(1)
      end

      it 'assigns a newly created loan as @loan' do
        post :create, params: {loan: valid_attributes}, session: valid_session
        expect(assigns(:loan)).to be_a(Loan)
        expect(assigns(:loan)).to be_persisted
      end

      it 'redirects to the created loan' do
        post :create, params: {loan: valid_attributes}, session: valid_session
        expect(response).to redirect_to(Loan.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved loan as @loan' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Loan).to receive(:save).and_return(false)
        post :create, params: {loan: {invalid: 'parms'}}, session: valid_session
        expect(assigns(:loan)).to be_a_new(Loan)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Loan).to receive(:save).and_return(false)
        post :create, params: {loan: {invalid: 'parms'}}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested loan' do
        loan = Loan.create! valid_attributes
        # Assuming there are no other loans in the database, this
        # specifies that the Loan created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({supervisor_email: 'ugly'}).permit(:supervisor_email)
        expect_any_instance_of(Loan).to receive(:update).with(update_params)
        put :update, params: {id: loan.to_param, loan: update_params}, session: valid_session
      end

      it 'assigns the requested loan as @loan' do
        loan = Loan.create! valid_attributes
        put :update, params: {id: loan.to_param, loan: valid_attributes}, session: valid_session
        expect(assigns(:loan)).to eq(loan)
      end

      it 'redirects to the loan' do
        loan = Loan.create! valid_attributes
        put :update, params: {id: loan.to_param, loan: valid_attributes}, session: valid_session
        expect(response).to redirect_to(loan)
      end
    end

    describe 'with invalid params' do
      it 'assigns the loan as @loan' do
        loan = Loan.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Loan).to receive(:save).and_return(false)
        put :update, params: {id: loan.to_param, loan: {invalid: 'parms'}}, session: valid_session
        expect(assigns(:loan)).to eq(loan)
      end

      it "re-renders the 'edit' template" do
        loan = Loan.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(Loan).to receive(:save).and_return(false)
        put :update, params: {id: loan.to_param, loan: {invalid: 'parms'}}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested loan' do
      loan = Loan.create! valid_attributes
      expect {
        delete :destroy, params: {id: loan.to_param}, session: valid_session
      }.to change(Loan, :count).by(-1)
    end

    it 'redirects to the loans list' do
      loan = Loan.create! valid_attributes
      delete :destroy, params: {id: loan.to_param}, session: valid_session
      expect(response).to redirect_to(loans_url)
    end
  end

end
