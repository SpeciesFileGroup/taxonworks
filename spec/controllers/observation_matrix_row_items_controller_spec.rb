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

RSpec.describe ObservationMatrixRowItemsController, type: :controller do

  before { sign_in }

  # This should return the minimal set of attributes required to create a valid
  # MatrixRowItem. As you add validations to MatrixRowItem, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_observation_matrix_row_item).attributes)
  }

  let(:invalid_attributes) {
    valid_attributes.merge('observation_matrix_id' => nil)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # MatrixRowItemsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all matrix_row_items as @observation_matrix_row_items' do
      observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to eq([observation_matrix_row_item])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested observation_matrix_row_item as @observation_matrix_row_item' do
      observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
      get :show, params: {id: observation_matrix_row_item.to_param}, session: valid_session
      expect(assigns(:observation_matrix_row_item)).to eq(observation_matrix_row_item)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested matrix_row_item as @observation_matrix_row_item' do
      observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
      get :edit, params: {id: observation_matrix_row_item.to_param}, session: valid_session
      expect(assigns(:observation_matrix_row_item)).to eq(observation_matrix_row_item)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new MatrixRowItem' do
        expect {
          post :create, params: {observation_matrix_row_item: valid_attributes}, format: :json, session: valid_session
        }.to change(ObservationMatrixRowItem, :count).by(1)
      end

      it 'assigns a newly created matrix_row_item as @observation_matrix_row_item' do
        post :create, params: {observation_matrix_row_item: valid_attributes}, format: :json, session: valid_session
        expect(assigns(:observation_matrix_row_item)).to be_a(ObservationMatrixRowItem)
        expect(assigns(:observation_matrix_row_item)).to be_persisted
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved matrix_row_item as @observation_matrix_row_item' do
        post :create, params: {observation_matrix_row_item: invalid_attributes}, format: :json, session: valid_session
        expect(assigns(:observation_matrix_row_item).metamorphosize).to be_a_new(ObservationMatrixRowItem)
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let!(:new_attributes) {
        { observation_matrix_id: FactoryBot.create(:valid_observation_matrix).id }
      }

      it 'updates the requested matrix_row_item' do
        observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
        put :update, params: {id: observation_matrix_row_item.to_param, observation_matrix_row_item: new_attributes}, format: :json, session: valid_session
        observation_matrix_row_item.reload
        expect(observation_matrix_row_item.observation_matrix_id).to eq(new_attributes[:observation_matrix_id])
      end

      it 'assigns the requested matrix_row_item as @observation_matrix_row_item' do
        observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
        put :update, params: {id: observation_matrix_row_item.to_param, observation_matrix_row_item: valid_attributes}, format: :json, session: valid_session
        expect(assigns(:observation_matrix_row_item)).to eq(observation_matrix_row_item)
      end
    end

    context 'with invalid params' do
      it 'assigns the matrix_row_item as @observation_matrix_row_item' do
        observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
        put :update, params: {id: observation_matrix_row_item.to_param, observation_matrix_row_item: invalid_attributes}, format: :json, session: valid_session
        expect(assigns(:observation_matrix_row_item)).to eq(observation_matrix_row_item)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the requested matrix_row_item' do
      observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
      expect {
        delete :destroy, params: {id: observation_matrix_row_item.to_param}, session: valid_session
      }.to change(ObservationMatrixRowItem, :count).by(-1)
    end

    it 'redirects to the matrix_row_items list' do
      observation_matrix_row_item = ObservationMatrixRowItem.create! valid_attributes
      delete :destroy, params: {id: observation_matrix_row_item.to_param}, session: valid_session
      expect(response).to redirect_to(observation_matrix_row_items_url)
    end
  end

end
