require 'rails_helper'

describe ::CollectionObjectsController, type: :controller do
  before(:each) {
    sign_in
  }

  let(:valid_attributes) {
    strip_housekeeping_attributes(FactoryBot.build(:valid_collection_object).attributes)
  }

  let(:valid_session) { {} }

  describe 'GET list' do
    it 'with no other parameters, assigns 20/page collection_objects as @collection_objects' do
      collection_object = CollectionObject.create! valid_attributes
      get :list, params: {}, session: valid_session
      expect(assigns(:collection_objects)).to include(collection_object)
    end

    it 'renders the list template' do
      get :list, params: {}, session: valid_session
      expect(response).to render_template('list')
    end
  end

  describe 'GET index' do
    it 'assigns all collection_objects as @recent_objects' do
      collection_object = CollectionObject.create! valid_attributes
      get :index, params: {}, session: valid_session
      expect(assigns(:recent_objects)).to eq([collection_object])
    end
  end

  describe 'GET show' do
    
    it 'assigns the requested collection_object as @collection_object' do
      collection_object = CollectionObject.create! valid_attributes
      get :show, params: {id: collection_object.to_param}, session: valid_session
      expect(assigns(:collection_object)).to eq(collection_object)
    end

    context 'JSON format request' do
      render_views
      let(:collection_object) do
        CollectionObject.create! valid_attributes.merge(
          {
            depictions_attributes: [
              {
                image_attributes: {
                  image_file: Rack::Test::UploadedFile.new((Rails.root + 'spec/files/images/tiny.png'),
                                                  'image/png')
                }
              }
            ]
          }
        )
      end
      
    end
  end

  describe 'GET by_identifier' do
    render_views
    let(:namespace) { FactoryBot.create(:valid_namespace, short_name: 'ABCD') }
    let!(:collection_object) do
      CollectionObject.create! valid_attributes.merge(
        {identifiers_attributes: [{identifier: '123', type: 'Identifier::Local::CatalogNumber', namespace: namespace}]})
    end

    context 'valid identifier' do
      before {get :by_identifier, params: {identifier: 'ABCD 123', format: :json}, session: valid_session}

      let (:data) { JSON.parse(response.body) }

      it 'returns a successful JSON response' do
        expect(data['success']).to be true
      end

      describe 'JSON data contents' do
        it 'has a request object' do
          expect(data['request']).to be_truthy
        end

        it 'has a result object' do
          expect(data['result']).to be_truthy
        end

        describe 'request attributes' do
          let(:request) { data['request'] }

          it 'has a params attribute' do
            expect(request['params']).to be_truthy
          end

          describe 'params attributes' do
            let(:params) { request['params'] }

            it 'has a project_id attribute' do
              expect(params['project_id']).to eq(1)
            end

            it 'has an identifier attribute' do
              expect(params['identifier']).to eq('ABCD 123')
            end
          end
        end

        describe 'result attributes' do
          let (:result) { data['result'] }

          it 'has a collection_objects array attribute' do
            expect(result['collection_objects'].length).to eq(1)
          end

          describe 'collection_objects items attributes' do
            let(:item) { result['collection_objects'].first }

            it 'has an id attribute' do
              expect(item['id']).to eq(collection_object.id)
            end

            it 'has an endpoint URL' do
              expect(item['url']).to eq(collection_object_url(collection_object))
            end
          end
        end
      end
    end

    context 'invalid identifier' do
      before {get :by_identifier, params: {identifier: 'FOO', format: :json}, session: valid_session}

      it 'returns 404 HTTP status' do
        expect(response.status).to eq(404)
      end

      it 'returns an unsuccessful JSON response' do
        expect(JSON.parse(response.body)).to eq({'success' => false})
      end
    end

  end

  describe 'GET new' do
    it 'assigns a new collection_object as @collection_object' do
      get :new, params: {}, session: valid_session
      expect(assigns(:collection_object)).to be_a_new(CollectionObject)
    end
  end

  describe 'GET edit' do
    it 'assigns the requested collection_object as @collection_object' do
      collection_object = CollectionObject.create! valid_attributes
      get :edit, params: {id: collection_object.to_param}, session: valid_session
      expect(assigns(:collection_object)).to eq(collection_object)
    end
  end

  describe 'POST create' do
    describe 'with valid params' do
      it 'creates a new CollectionObject' do
        expect {
          post :create, params: {collection_object: valid_attributes}, session: valid_session
        }.to change(CollectionObject, :count).by(1)
      end

      it 'assigns a newly created collection_object as @collection_object' do
        post :create, params: {collection_object: valid_attributes}, session: valid_session
        expect(assigns(:collection_object)).to be_a(CollectionObject)
        expect(assigns(:collection_object)).to be_persisted
      end

      it 'redirects to the created collection_object' do
        post :create, params: {collection_object: valid_attributes}, session: valid_session
        expect(response).to redirect_to(CollectionObject.last.metamorphosize)
      end
    end

    describe 'with invalid params' do
      it 'assigns a newly created but unsaved collection_object as @collection_object' do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        post :create, params: {collection_object: {'total' => 'invalid value'}}, session: valid_session
        expect(assigns(:collection_object)).to be_a_new(CollectionObject)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        post :create, params: {collection_object: {'total' => 'invalid value'}}, session: valid_session
        expect(response).to render_template('new')
      end
    end
  end

  describe 'PUT update' do
    describe 'with valid params' do
      it 'updates the requested collection_object' do
        collection_object = CollectionObject.create! valid_attributes
        # Assuming there are no other collection_objects in the database, this
        # specifies that the CollectionObject created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        update_params = ActionController::Parameters.new({total: '1'}).permit(:total)
        expect_any_instance_of(CollectionObject).to receive(:update).with(update_params)
        put :update, params: {id: collection_object.to_param, collection_object: update_params}, session: valid_session
      end

      it 'assigns the requested collection_object as @collection_object' do
        collection_object = CollectionObject.create! valid_attributes
        put :update, params: {id: collection_object.to_param, collection_object: valid_attributes}, session: valid_session
        expect(assigns(:collection_object)).to eq(collection_object.metamorphosize)
      end

      it 'redirects to the collection_object' do
        collection_object = CollectionObject.create! valid_attributes
        put :update, params: {id: collection_object.to_param, collection_object: valid_attributes}, session: valid_session
        expect(response).to redirect_to(collection_object.becomes(CollectionObject))
      end
    end

    describe 'with invalid params' do
      it 'assigns the collection_object as @collection_object' do
        collection_object = CollectionObject.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        put :update, params: {id: collection_object.to_param, collection_object: {'total' => 'invalid value'}}, session: valid_session
        expect(assigns(:collection_object)).to eq(collection_object)
      end

      it "re-renders the 'edit' template" do
        collection_object = CollectionObject.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        allow_any_instance_of(CollectionObject).to receive(:save).and_return(false)
        put :update, params: {id: collection_object.to_param, collection_object: {'total' => 'invalid value'}}, session: valid_session
        expect(response).to render_template('edit')
      end
    end
  end

  describe 'DELETE destroy' do
    it 'destroys the requested collection_object' do
      collection_object = CollectionObject.create! valid_attributes
      expect {
        delete :destroy, params: {id: collection_object.to_param}, session: valid_session
      }.to change(CollectionObject, :count).by(-1)
    end

    it 'redirects to the collection_objects list' do
      request.env['HTTP_REFERER'] = collection_objects_url
      collection_object = CollectionObject.create! valid_attributes
      delete :destroy, params: {id: collection_object.to_param}, session: valid_session
      expect(response).to redirect_to(collection_objects_url)
    end
  end

end
