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

describe TaxonNamesController, type: :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well.
  let(:root_name) { FactoryBot.create(:root_taxon_name) }
  let(:valid_attributes) { {name: 'Aidae', rank_class: Ranks.lookup(:iczn, 'family'), parent_id: root_name.id, type: 'Protonym' }}

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TaxonNamesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  describe 'GET list' do
    it 'with no other parameters, assigns 20/page taxon_names as @taxon_names' do
      taxon_name = TaxonName.create! valid_attributes
      get :list, params: {}, session: valid_session
      expect(assigns(:taxon_names)).to include(taxon_name.becomes(taxon_name.type.constantize))
    end

    it 'renders the list template' do
      get :list, params: {}, session: valid_session
      expect(response).to render_template('list')
    end
  end

  describe 'GET index' do
    it 'assigns all taxon_names as @taxon_names' do
      taxon_name = TaxonName.create!(valid_attributes)
      get :index, params: {}, session: valid_session
      # The following means that @taxon_names = TaxonName.all in the controller.
      # todo @mjy following line (coming from Otu) is slightly different than others, i.e. others eq(taxon_name)
      expect(assigns(:recent_objects)).to include(taxon_name.becomes(taxon_name.type.constantize))
    end
  end

  describe 'GET show' do
    it 'assigns the requested taxon_name as @taxon_name' do
      taxon_name = TaxonName.create! valid_attributes
      get :show, params: {id: taxon_name.to_param}, session: valid_session
      expect(assigns(:taxon_name)).to eq(taxon_name.becomes(taxon_name.type.constantize))
    end
  end

  describe 'GET new' do
    it 'assigns a new taxon_name as @taxon_name' do
      get :new, params: {}, session: valid_session
      expect(assigns(:taxon_name)).to be_a_new(TaxonName)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested taxon_name as @taxon_name' do
      taxon_name = TaxonName.create! valid_attributes
      get :edit, params: {id: taxon_name.to_param}, session: valid_session
      expect(assigns(:taxon_name)).to eq(taxon_name.becomes(taxon_name.type.constantize))
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new TaxonName' do
        expect {
          post :create, params: {taxon_name: valid_attributes}, session: valid_session
        }.to change(TaxonName, :count).by(2) # both root and a name are created
      end

      it 'assigns a newly created taxon_name as @taxon_name' do
        post :create, params: {taxon_name: valid_attributes}, session: valid_session
        expect(assigns(:taxon_name)).to be_a(TaxonName)
        expect(assigns(:taxon_name)).to be_persisted
      end

      it 'redirects to the created taxon_name' do
        post :create, params: {taxon_name: valid_attributes}, session: valid_session
        expect(response).to redirect_to(TaxonName.last.becomes(TaxonName))
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved taxon_name as @taxon_name' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonName).to receive(:save).and_return(false)
        post :create, params: {taxon_name: {'name' => 'invalid value'}}, session: valid_session
        expect(assigns(:taxon_name)).to be_a_new(TaxonName)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonName).to receive(:save).and_return(false)
        post :create, params: {taxon_name: {'name' => 'invalid value'}}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested taxon_name' do
        taxon_name = TaxonName.create! valid_attributes
        # Assuming there are no other taxon_names in the database, this
        # specifies that the TaxonName created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({'name' => 'MyString'}).permit(:name)
        expect_any_instance_of(TaxonName).to receive(:update).with(update_params)
        put :update, params: {id: taxon_name.to_param, taxon_name: {'name' => 'MyString'}}, session: valid_session
      end

      it 'assigns the requested taxon_name as @taxon_name' do
        taxon_name = TaxonName.create! valid_attributes
        put :update, params: {id: taxon_name.to_param, taxon_name: valid_attributes}, session: valid_session
        expect(assigns(:taxon_name)).to eq(taxon_name.becomes(taxon_name.type.constantize))
      end

      it 'redirects to the taxon_name' do
        taxon_name = TaxonName.create! valid_attributes
        put :update, params: {id: taxon_name.to_param, taxon_name: valid_attributes}, session: valid_session
        expect(response).to redirect_to(taxon_name.becomes(TaxonName))
      end
    end

    describe 'with invalid params' do
      it 'assigns the taxon_name as @taxon_name' do
        taxon_name = TaxonName.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonName).to receive(:save).and_return(false)
        put :update, params: {id: taxon_name.to_param, taxon_name: {'name' => 'invalid value'}}, session: valid_session
        expect(assigns(:taxon_name)).to eq(taxon_name.becomes(taxon_name.type.constantize))
      end

      it "re-renders the 'edit' template" do
        taxon_name = TaxonName.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonName).to receive(:save).and_return(false)
        put :update, params: {id: taxon_name.to_param, taxon_name: {'name' => 'invalid value'}}, session: valid_session
        expect(response).to render_template('edit')
      end
    end

    include_examples 'DELETE #destroy', TaxonName
  end
end
