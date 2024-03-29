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

RSpec.describe SequenceRelationshipsController, type: :controller do

  before(:each){
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # SequenceRelationship. As you add validations to SequenceRelationship, be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_sequence_relationship).attributes)
  }

  let(:invalid_attributes) {
    {subject_sequence_id: nil, type: nil, object_sequence_id: nil}
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # SequenceRelationshipsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET #index' do
    it 'assigns all sequence_relationships as @sequence_relationships' do
      sequence_relationship = SequenceRelationship.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to eq([sequence_relationship])
    end
  end

  describe 'GET #show' do
    it 'assigns the requested sequence_relationship as @sequence_relationship' do
      sequence_relationship = SequenceRelationship.create! valid_attributes
      get :show, params: {id: sequence_relationship.to_param}, session: valid_session
      expect(assigns(:sequence_relationship)).to eq(sequence_relationship)
    end
  end

  describe 'GET #new' do
    it 'assigns a new sequence_relationship as @sequence_relationship' do
      get :new, params: {}, session: valid_session
      expect(assigns(:sequence_relationship)).to be_a_new(SequenceRelationship)
    end
  end

  describe 'GET #edit' do
    it 'assigns the requested sequence_relationship as @sequence_relationship' do
      sequence_relationship = SequenceRelationship.create! valid_attributes
      get :edit, params: {id: sequence_relationship.to_param}, session: valid_session
      expect(assigns(:sequence_relationship)).to eq(sequence_relationship)
    end
  end

  describe 'POST #create' do
    context 'with valid params' do
      it 'creates a new SequenceRelationship' do
        expect {
          post :create, params: {sequence_relationship: valid_attributes}, session: valid_session
        }.to change(SequenceRelationship, :count).by(1)
      end

      it 'assigns a newly created sequence_relationship as @sequence_relationship' do
        post :create, params: {sequence_relationship: valid_attributes}, session: valid_session
        expect(assigns(:sequence_relationship)).to be_a(SequenceRelationship)
        expect(assigns(:sequence_relationship)).to be_persisted
      end

      it 'redirects to the created sequence_relationship' do
        post :create, params: {sequence_relationship: valid_attributes}, session: valid_session
        expect(response).to redirect_to(SequenceRelationship.last.metamorphosize)
      end
    end

    context 'with invalid params' do
      it 'assigns a newly created but unsaved sequence_relationship as @sequence_relationship' do
        post :create, params: {sequence_relationship: invalid_attributes}, session: valid_session
        expect(assigns(:sequence_relationship)).to be_a_new(SequenceRelationship)
      end

      it "re-renders the 'new' template" do
        post :create, params: {sequence_relationship: invalid_attributes}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      let(:new_attributes) {
        {subject_sequence_id: FactoryBot.create(:valid_sequence).id,
         object_sequence_id:  FactoryBot.create(:valid_sequence).id,
         type:                SequenceRelationship::ReversePrimer}
      }

      it 'updates the requested sequence_relationship' do
        sequence_relationship = SequenceRelationship.create! valid_attributes
        put :update, params: {id: sequence_relationship.to_param, sequence_relationship: new_attributes}, session: valid_session
        sequence_relationship.reload

        expect(sequence_relationship.subject_sequence_id == new_attributes[:subject_sequence_id] && sequence_relationship.object_sequence_id == new_attributes[:object_sequence_id])
      end

      it 'assigns the requested sequence_relationship as @sequence_relationship' do
        sequence_relationship = SequenceRelationship.create! valid_attributes
        put :update, params: {id: sequence_relationship.to_param, sequence_relationship: valid_attributes}, session: valid_session
        expect(assigns(:sequence_relationship)).to eq(sequence_relationship)
      end

      it 'redirects to the sequence_relationship' do
        sequence_relationship = SequenceRelationship.create! valid_attributes
        put :update, params: {id: sequence_relationship.to_param, sequence_relationship: valid_attributes}, session: valid_session
        expect(response).to redirect_to(sequence_relationship.metamorphosize)
      end
    end

    context 'with invalid params' do
      it 'assigns the sequence_relationship as @sequence_relationship' do
        sequence_relationship = SequenceRelationship.create! valid_attributes
        put :update, params: {id: sequence_relationship.to_param, sequence_relationship: invalid_attributes}, session: valid_session
        expect(assigns(:sequence_relationship)).to eq(sequence_relationship)
      end

      it "re-renders the 'edit' template" do
        sequence_relationship = SequenceRelationship.create! valid_attributes
        put :update, params: {id: sequence_relationship.to_param, sequence_relationship: invalid_attributes}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  include_examples 'DELETE #destroy', SequenceRelationship
end
