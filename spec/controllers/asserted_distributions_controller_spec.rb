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

describe AssertedDistributionsController, type: :controller do
  before(:each) {
    sign_in
  }

#   # This should return the minimal set of attributes required to create a valid
#   # AssertedDistribution. As you add validations to AssertedDistribution, be sure to
#   # adjust the attributes here as well.
  let(:valid_attributes) {
    h = strip_housekeeping_attributes( FactoryBot.build(:valid_asserted_distribution).attributes)
    h.merge(origin_citation_attributes: {source_id: FactoryBot.create(:valid_source).id} )
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AssertedDistributionsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET list' do
    it 'with no other parameters, assigns 20/page asserted_distributions as @controlled_vocabulary_terms' do
      asserted_distribution = AssertedDistribution.create! valid_attributes
      get :list, params: {}, session: valid_session
      expect(assigns(:asserted_distributions)).to include(asserted_distribution)
    end

    it 'renders the list template' do
      get :list, params: {}, session: valid_session
      expect(response).to render_template('list')
    end
  end

  describe 'GET index' do
    it 'assigns all asserted_distributions as @asserted_distributions' do
      asserted_distribution = AssertedDistribution.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to include(asserted_distribution)
    end
  end

  describe 'GET show' do
    it 'assigns the requested asserted_distribution as @asserted_distribution' do
      asserted_distribution = AssertedDistribution.create! valid_attributes
      get :show, params: {id: asserted_distribution.to_param}, session: valid_session
      expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
    end
  end

  describe 'GET new' do
    it 'assigns a new asserted_distribution as @asserted_distribution' do
      # get :new, {}, session: valid_session
      get :new, params: {}, session: valid_session
      expect(assigns(:asserted_distribution)).to be_a_new(AssertedDistribution)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested asserted_distribution as @asserted_distribution' do
      asserted_distribution = AssertedDistribution.create! valid_attributes
      get :edit, params: {id: asserted_distribution.to_param}, session: valid_session
      expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new AssertedDistribution' do
        expect {
          # post :create, {:asserted_distribution => valid_attributes}, session: valid_session
          post :create, params: {asserted_distribution: valid_attributes}, session: valid_session
        }.to change(AssertedDistribution, :count).by(1)
      end

      it 'assigns a newly created asserted_distribution as @asserted_distribution' do
        post :create, params: {asserted_distribution: valid_attributes}, session: valid_session
        expect(assigns(:asserted_distribution)).to be_a(AssertedDistribution)
        expect(assigns(:asserted_distribution)).to be_persisted
      end

      it 'redirects to the created asserted_distribution' do
        post :create, params: {asserted_distribution: valid_attributes}, session: valid_session
        expect(response).to redirect_to(AssertedDistribution.last)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved asserted_distribution as @asserted_distribution' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AssertedDistribution).to receive(:save).and_return(false)
        post :create, params: {asserted_distribution: {verbatim_label: 'invalid value'}}, session: valid_session
        expect(assigns(:asserted_distribution)).to be_a_new(AssertedDistribution)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AssertedDistribution).to receive(:save).and_return(false)
        post :create, params: {asserted_distribution: {verbatim_label: 'invalid value'}}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do

      it 'updates the requested asserted_distribution' do
        asserted_distribution = AssertedDistribution.create! valid_attributes
        # Assuming there are no other asserted_distributions in the database, this
        # specifies that the AssertedDistribution created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({is_absent: 'true'}).permit(:is_absent)
        expect_any_instance_of(AssertedDistribution).to receive(:update).with(update_params)
        put :update, params: {id: asserted_distribution.to_param, asserted_distribution: {is_absent: 'true'}}, session: valid_session
      end

      it 'assigns the requested asserted_distribution as @asserted_distribution' do
        asserted_distribution = AssertedDistribution.create! valid_attributes
        put :update, params: {id: asserted_distribution.to_param, asserted_distribution: {is_absent: 'true'}}, session: valid_session
        expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
      end

      it 'redirects to the asserted_distribution' do
        asserted_distribution = AssertedDistribution.create! valid_attributes
        put :update, params: {id: asserted_distribution.to_param, asserted_distribution: {is_absent: 'true'}}, session: valid_session
        expect(response).to redirect_to(asserted_distribution)
      end
    end

    describe 'with invalid params' do
      it 'assigns the asserted_distribution as @asserted_distribution' do
        asserted_distribution = AssertedDistribution.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AssertedDistribution).to receive(:save).and_return(false)
        put :update, params: {id: asserted_distribution.to_param, asserted_distribution: {verbatim_label: 'invalid value'}}, session: valid_session
        expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
      end

      it "re-renders the 'edit' template" do
        asserted_distribution = AssertedDistribution.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AssertedDistribution).to receive(:save).and_return(false)
        put :update, params: {id: asserted_distribution.to_param, asserted_distribution: {verbatim_label: 'invalid value'}}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  include_examples 'DELETE #destroy', AssertedDistribution
end



# RSpec.describe AssertedDistributionsController, :type => :controller do
#
#   # This should return the minimal set of attributes required to create a valid
#   # AssertedDistribution. As you add validations to AssertedDistribution, be sure to
#   # adjust the attributes here as well.
#   let(:valid_attributes) {
#     skip("Add a hash of attributes valid for your model")
#   }
#
#   let(:invalid_attributes) {
#     skip("Add a hash of attributes invalid for your model")
#   }
#
#   # This should return the minimal set of values that should be in the session
#   # in order to pass any filters (e.g. authentication) defined in
#   # AssertedDistributionsController. Be sure to keep this updated too.
#   let(:valid_session) { {} }
#
#   describe "GET index" do
#     it "assigns all asserted_distributions as @asserted_distributions" do
#       asserted_distribution = AssertedDistribution.create! valid_attributes
#       get :index, {}, session: valid_session
#       expect(assigns(:asserted_distributions)).to eq([asserted_distribution])
#     end
#   end
#
#   describe "GET show" do
#     it "assigns the requested asserted_distribution as @asserted_distribution" do
#       asserted_distribution = AssertedDistribution.create! valid_attributes
#       get :show, {id: asserted_distribution.to_param}, session: valid_session
#       expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
#     end
#   end
#
#   describe "GET new" do
#     it "assigns a new asserted_distribution as @asserted_distribution" do
#       get :new, {}, session: valid_session
#       expect(assigns(:asserted_distribution)).to be_a_new(AssertedDistribution)
#     end
#   end
#
#   describe "GET edit" do
#     it "assigns the requested asserted_distribution as @asserted_distribution" do
#       asserted_distribution = AssertedDistribution.create! valid_attributes
#       get :edit, {id: asserted_distribution.to_param}, session: valid_session
#       expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
#     end
#   end
#
#   describe "POST create" do
#     describe "with valid params" do
#       it "creates a new AssertedDistribution" do
#         expect {
#           post :create, {:asserted_distribution => valid_attributes}, session: valid_session
#         }.to change(AssertedDistribution, :count).by(1)
#       end
#
#       it "assigns a newly created asserted_distribution as @asserted_distribution" do
#         post :create, {:asserted_distribution => valid_attributes}, session: valid_session
#         expect(assigns(:asserted_distribution)).to be_a(AssertedDistribution)
#         expect(assigns(:asserted_distribution)).to be_persisted
#       end
#
#       it "redirects to the created asserted_distribution" do
#         post :create, {:asserted_distribution => valid_attributes}, session: valid_session
#         expect(response).to redirect_to(AssertedDistribution.last)
#       end
#     end
#
#     describe "with invalid params" do
#       it "assigns a newly created but unsaved asserted_distribution as @asserted_distribution" do
#         post :create, {:asserted_distribution => invalid_attributes}, session: valid_session
#         expect(assigns(:asserted_distribution)).to be_a_new(AssertedDistribution)
#       end
#
#       it "re-renders the 'new' template" do
#         post :create, {:asserted_distribution => invalid_attributes}, session: valid_session
#         expect(response).to render_template("new")
#       end
#     end
#   end
#
#   describe "PUT update" do
#     describe "with valid params" do
#       let(:new_attributes) {
#         skip("Add a hash of attributes valid for your model")
#       }
#
#       it "updates the requested asserted_distribution" do
#         asserted_distribution = AssertedDistribution.create! valid_attributes
#         put :update, {id: asserted_distribution.to_param, :asserted_distribution => new_attributes}, session: valid_session
#         asserted_distribution.reload
#         skip("Add assertions for updated state")
#       end
#
#       it "assigns the requested asserted_distribution as @asserted_distribution" do
#         asserted_distribution = AssertedDistribution.create! valid_attributes
#         put :update, {id: asserted_distribution.to_param, :asserted_distribution => valid_attributes}, session: valid_session
#         expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
#       end
#
#       it "redirects to the asserted_distribution" do
#         asserted_distribution = AssertedDistribution.create! valid_attributes
#         put :update, {id: asserted_distribution.to_param, :asserted_distribution => valid_attributes}, session: valid_session
#         expect(response).to redirect_to(asserted_distribution)
#       end
#     end
#
#     describe "with invalid params" do
#       it "assigns the asserted_distribution as @asserted_distribution" do
#         asserted_distribution = AssertedDistribution.create! valid_attributes
#         put :update, {id: asserted_distribution.to_param, :asserted_distribution => invalid_attributes}, session: valid_session
#         expect(assigns(:asserted_distribution)).to eq(asserted_distribution)
#       end
#
#       it "re-renders the 'edit' template" do
#         asserted_distribution = AssertedDistribution.create! valid_attributes
#         put :update, {id: asserted_distribution.to_param, :asserted_distribution => invalid_attributes}, session: valid_session
#         expect(response).to render_template("edit")
#       end
#     end
#   end
#
#   describe "DELETE destroy" do
#     it "destroys the requested asserted_distribution" do
#       asserted_distribution = AssertedDistribution.create! valid_attributes
#       expect {
#         delete :destroy, {id: asserted_distribution.to_param}, session: valid_session
#       }.to change(AssertedDistribution, :count).by(-1)
#     end
#
#     it "redirects to the asserted_distributions list" do
#       asserted_distribution = AssertedDistribution.create! valid_attributes
#       delete :destroy, {id: asserted_distribution.to_param}, session: valid_session
#       expect(response).to redirect_to(asserted_distributions_url)
#     end
#   end
#
# end
