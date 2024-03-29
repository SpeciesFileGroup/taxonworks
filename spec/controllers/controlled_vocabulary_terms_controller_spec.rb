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

describe ControlledVocabularyTermsController, type: :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_controlled_vocabulary_term).attributes)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # ControlledVocabularyTermsController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET list' do
    it 'with no other parameters, assigns 20/page controlled_vocabulary_terms as @controlled_vocabulary_terms' do
      controlled_vocabulary_term = ControlledVocabularyTerm.create! valid_attributes
      get :list, params: {}, session: valid_session
      expect(assigns(:controlled_vocabulary_terms)).to include(controlled_vocabulary_term)
    end

    it 'renders the list template' do
      get :list, params: {}, session: valid_session
      expect(response).to render_template('list')
    end
  end

  describe 'GET index' do
    it 'assigns all controlled_vocabulary_terms as @recent_objects' do
      controlled_vocabulary_term = ControlledVocabularyTerm.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to include(controlled_vocabulary_term)
    end
  end

  describe 'GET show' do
    it 'assigns the requested controlled_vocabulary_term as @controlled_vocabulary_term' do
      controlled_vocabulary_term = ControlledVocabularyTerm.create! valid_attributes
      get :show, params: {id: controlled_vocabulary_term.to_param}, session: valid_session
      expect(assigns(:controlled_vocabulary_term)).to eq(controlled_vocabulary_term)
    end
  end

  describe 'GET new' do
    it 'assigns a new controlled_vocabulary_term as @controlled_vocabulary_term' do
      get :new, params: {}, session: valid_session
      expect(response).to redirect_to(manage_controlled_vocabulary_terms_task_path)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested controlled_vocabulary_term as @controlled_vocabulary_term' do
      controlled_vocabulary_term = ControlledVocabularyTerm.create! valid_attributes
      get :edit, params: {id: controlled_vocabulary_term.to_param}, session: valid_session
      expect(response).to redirect_to(manage_controlled_vocabulary_terms_task_path(controlled_vocabulary_term_id: controlled_vocabulary_term.to_param ))
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      before { 
        request.env['HTTP_REFERER'] = manage_controlled_vocabulary_terms_task_path
      }

      it 'creates a new ControlledVocabularyTerm' do
        expect {
          post :create, params: {controlled_vocabulary_term: valid_attributes}, session: valid_session, format: :json
        }.to change(ControlledVocabularyTerm, :count).by(1)
      end

      it 'assigns a newly created controlled_vocabulary_term as @controlled_vocabulary_term' do
        post :create, params: {controlled_vocabulary_term: valid_attributes}, session: valid_session, format: :json
        expect(assigns(:controlled_vocabulary_term)).to be_a(ControlledVocabularyTerm)
        expect(assigns(:controlled_vocabulary_term)).to be_persisted
      end
    end

    describe 'with invalid params' do
      before { 
        request.env['HTTP_REFERER'] = manage_controlled_vocabulary_terms_task_path
      }
      it 'assigns a newly created but unsaved controlled_vocabulary_term as @controlled_vocabulary_term' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ControlledVocabularyTerm).to receive(:save).and_return(false)
        post :create, params: {controlled_vocabulary_term: {'name' => nil}}, session: valid_session, format: :json
        expect(assigns(:controlled_vocabulary_term)).to be_a_new(ControlledVocabularyTerm)
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      let(:update_params) {ActionController::Parameters.new({type: ''}).permit(:type)}
      it 'updates the requested controlled_vocabulary_term' do
        controlled_vocabulary_term = ControlledVocabularyTerm.create! valid_attributes
        # Assuming there are no other controlled_vocabulary_terms in the database, this
        # specifies that the ControlledVocabularyTerm created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(ControlledVocabularyTerm).to receive(:update).with(update_params)
        put :update, params: {id: controlled_vocabulary_term.to_param, controlled_vocabulary_term: update_params}, session: valid_session, format: :json
      end

      it 'assigns the requested controlled_vocabulary_term as @controlled_vocabulary_term' do
        controlled_vocabulary_term = ControlledVocabularyTerm.create! valid_attributes
        put :update, params: {id: controlled_vocabulary_term.to_param, controlled_vocabulary_term: valid_attributes}, session: valid_session, format: :json
        expect(assigns(:controlled_vocabulary_term)).to eq(controlled_vocabulary_term)
      end
    end

    describe 'with invalid params' do
      it 'assigns the controlled_vocabulary_term as @controlled_vocabulary_term' do
        controlled_vocabulary_term = ControlledVocabularyTerm.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(ControlledVocabularyTerm).to receive(:save).and_return(false)
        put :update, params: {id: controlled_vocabulary_term.to_param, controlled_vocabulary_term: {'type' => 'invalid value'}}, session: valid_session, format: :json
        expect(assigns(:controlled_vocabulary_term)).to eq(controlled_vocabulary_term)
      end
    end
  end

  include_examples 'DELETE #destroy', ControlledVocabularyTerm
end
