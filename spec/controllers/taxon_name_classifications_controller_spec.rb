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

describe TaxonNameClassificationsController, type: :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # Georeference. As you add validations to Georeference be sure to
  # adjust the attributes here as well
  let(:root) {FactoryBot.create(:root_taxon_name)}
  let(:taxon_name) {Protonym.create!(parent: root, name: 'Biidae', rank_class: Ranks.lookup(:iczn, 'family'))}
  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_taxon_name_classification, taxon_name_id: taxon_name.to_param).attributes)
  }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # TaxonNameClassificationsController. Be sure to keep this updated too.
  let(:valid_session) {{}}

  before {
    request.env['HTTP_REFERER'] = list_otus_path # logical example
  }

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new TaxonNameClassification' do
        expect {
          post :create, params: {taxon_name_classification: valid_attributes}, session: valid_session
        }.to change(TaxonNameClassification, :count).by(1)
      end

      it 'assigns a newly created taxon_name_classification as @taxon_name_classification' do
        post :create, params: {taxon_name_classification: valid_attributes}, session: valid_session
        expect(assigns(:taxon_name_classification)).to be_a(TaxonNameClassification)
        expect(assigns(:taxon_name_classification)).to be_persisted
      end

      it 'redirects to the associated TaxonName page' do
        post :create, params: {taxon_name_classification: valid_attributes}, session: valid_session
        expect(response).to redirect_to(taxon_name_path(TaxonNameClassification.last.taxon_name))
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved taxon_name_classification as @taxon_name_classification' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonNameClassification).to receive(:save).and_return(false)
        post :create, params: {taxon_name_classification: {taxon_name_id: 'invalid value'}}, session: valid_session
        expect(assigns(:taxon_name_classification)).to be_a_new(TaxonNameClassification)
      end

      it 're-renders the :back template' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonNameClassification).to receive(:save).and_return(false)
        post :create, params: {taxon_name_classification: {taxon_name_id: 'invalid value'}}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested taxon_name_classification' do
        taxon_name_classification = TaxonNameClassification.create! valid_attributes
        # Assuming there are no other taxon_name_classifications in the database, this
        # specifies that the TaxonNameClassification created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({taxon_name_id: '1'}).permit(:taxon_name_id)
        expect_any_instance_of(TaxonNameClassification).to receive(:update).with(update_params)
        put :update, params: {id: taxon_name_classification.to_param, taxon_name_classification: {taxon_name_id: '1'}}, session: valid_session
      end

      it 'assigns the requested taxon_name_classification as @taxon_name_classification' do
        taxon_name_classification = TaxonNameClassification.create! valid_attributes
        put :update, params: {id: taxon_name_classification.to_param, taxon_name_classification: valid_attributes}, session: valid_session
        expect(assigns(:taxon_name_classification)).to eq(taxon_name_classification)
      end

      it 'redirects to :back' do
        taxon_name_classification = TaxonNameClassification.create! valid_attributes
        put :update, params: {id: taxon_name_classification.to_param, taxon_name_classification: valid_attributes}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end

    describe 'with invalid params' do
      it 'assigns the taxon_name_classification as @taxon_name_classification' do
        taxon_name_classification = TaxonNameClassification.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonNameClassification).to receive(:save).and_return(false)
        put :update, params: {id: taxon_name_classification.to_param, taxon_name_classification: {taxon_name_id: 'invalid value'}}, session: valid_session
        expect(assigns(:taxon_name_classification)).to eq(taxon_name_classification)
      end

      it 're-renders the :back template' do
        taxon_name_classification = TaxonNameClassification.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(TaxonNameClassification).to receive(:save).and_return(false)
        put :update, params: {id: taxon_name_classification.to_param, taxon_name_classification: {taxon_name_id: 'invalid value'}}, session: valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  include_examples 'DELETE #destroy', TaxonNameClassification
end
