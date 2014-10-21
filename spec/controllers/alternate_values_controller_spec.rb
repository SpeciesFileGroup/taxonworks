require 'rails_helper'

describe AlternateValuesController, :type => :controller do
  before(:each) {
    sign_in
  }

  # This should return the minimal set of attributes required to create a valid
  # AlternateValue. As you add validations to AlternateValue, be sure to
  # adjust the attributes here as well.
  let(:o) {FactoryGirl.create(:valid_source_bibtex)}
  let(:valid_attributes) { {alternate_object_id: o.id, alternate_object_type: o.class.to_s, value: "T.L.T.Q.", alternate_object_attribute: :title, type: 'AlternateValue::Abbreviation'} }

  # This should return the minimal set of values that should be in the session
  # in order to pass any filters (e.g. authentication) defined in
  # AlternateValuesController. Be sure to keep this updated too.
  let(:valid_session) { {} }

  before {
    request.env['HTTP_REFERER'] = list_otus_path # logical example
  }

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new AlternateValue' do
        expect {
          post :create, {:alternate_value => valid_attributes}, valid_session
        }.to change(AlternateValue, :count).by(1)
      end

      it 'assigns a newly created alternate_value as @alternate_value' do
        post :create, {:alternate_value => valid_attributes}, valid_session
        expect(assigns(:alternate_value)).to be_a(AlternateValue)
        expect(assigns(:alternate_value)).to be_persisted
      end

      it 'redirects to :back' do
        post :create, {:alternate_value => valid_attributes}, valid_session
        expect(response).to redirect_to(source_path(o))
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved alternate_value as @alternate_value' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AlternateValue).to receive(:save).and_return(false)
        post :create, {:alternate_value => {value: 'Bar'}}, valid_session
        expect(assigns(:alternate_value)).to be_a_new(AlternateValue)
      end

      it 're-renders the :back template' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AlternateValue).to receive(:save).and_return(false)
        post :create, {:alternate_value => {value: 'Foo'}}, valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested alternate_value' do
        alternate_value = AlternateValue.create! valid_attributes
        # Assuming there are no other alternate_values in the database, this
        # specifies that the AlternateValue created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        expect_any_instance_of(AlternateValue).to receive(:update).with({'value' => 'Smorf'})
        put :update, {:id => alternate_value.to_param, :alternate_value => {value: 'Smorf'}}, valid_session
      end

      it 'assigns the requested alternate_value as @alternate_value' do
        alternate_value = AlternateValue.create! valid_attributes
        put :update, {:id => alternate_value.to_param, :alternate_value => valid_attributes}, valid_session
        expect(assigns(:alternate_value)).to eq(alternate_value)
      end

      it 'redirects to :back' do
        alternate_value = AlternateValue.create! valid_attributes
        put :update, {:id => alternate_value.to_param, :alternate_value => valid_attributes}, valid_session
        expect(response).to redirect_to(source_path(o))
      end
    end

    describe 'with invalid params' do
      it 'assigns the alternate_value as @alternate_value' do
        alternate_value = AlternateValue.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AlternateValue).to receive(:save).and_return(false)
        put :update, {:id => alternate_value.to_param, :alternate_value => {foo: 'Bar'}}, valid_session
        expect(assigns(:alternate_value)).to eq(alternate_value)
      end

      it 're-renders the :back template' do
        alternate_value = AlternateValue.create!(valid_attributes)
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(AlternateValue).to receive(:save).and_return(false)
        put :update, {:id => alternate_value.to_param, :alternate_value => {value: 'Smorf'}}, valid_session
        expect(response).to redirect_to(list_otus_path)
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested alternate_value' do
      alternate_value = AlternateValue.create! valid_attributes
      expect {
        delete :destroy, {:id => alternate_value.to_param}, valid_session
      }.to change(AlternateValue, :count).by(-1)
    end

    it 'redirects to :back' do
      alternate_value = AlternateValue.create! valid_attributes
      delete :destroy, {:id => alternate_value.to_param}, valid_session
      expect(response).to redirect_to(list_otus_path)
    end
  end

end
