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

describe ImagesController, type: :controller do
  context 'signed in' do
    before(:each) {
      sign_in
    }

    # This should return the minimal set of attributes required to create a valid
    # Image. As you add validations to Image, be sure to
    # adjust the attributes here as well.
    let(:valid_attributes) {
      {image_file: Rack::Test::UploadedFile.new((Rails.root + 'spec/files/images/tiny.png'), 'image/png')}
    }

    let(:invalid_attributes) {
      strip_housekeeping_attributes(FactoryBot.build(:weird_image).attributes)
    }

    # This should return the minimal set of values that should be in the session
    # in order to pass any filters (e.g. authentication) defined in
    # ImagesController. Be sure to keep this updated too.
    let(:valid_session) { {} }

    describe 'GET list' do
      it 'with no other parameters, assigns 20/page images as @controlled_vocabulary_terms' do
        image = Image.create! valid_attributes
        get :list, params: {}, session: valid_session
        expect(assigns(:images)).to include(image)
      end

      it 'renders the list template' do
        get :list, params: {}, session: valid_session
        expect(response).to render_template('list')
      end
    end

    describe 'GET index' do
      it 'assigns all images as @images' do
        image = Image.create! valid_attributes
        get :index, params: {}, session: valid_session
        # expect(assigns(:images)).to eq([image])
        expect(assigns(:recent_objects)).to include(image)
      end
    end

    describe 'GET show' do
      let (:image) { Image.create! valid_attributes }

      it 'assigns the requested image as @image' do
        get :show, params: {id: image.to_param}, session: valid_session
        expect(assigns(:image)).to eq(image)
      end

      # TODO: Move all these tests out of controller to API
      context 'JSON format request' do
        render_views

        context 'valid image' do
          before { get :show, params: {id: image.to_param, format: :json}, session: valid_session }
          let (:data) { JSON.parse(response.body) }

          describe 'JSON data contents' do

            describe 'result attributes' do
              let (:result) { data }

              it 'has an id' do
                expect(result['id']).to eq(image.id)
              end

              it 'has image width' do
                expect(result['width']).to eq(image.width)
              end

              it 'has image height' do
                expect(result['height']).to eq(image.height)
              end

              it 'has image content type' do
                expect(result['content_type']).to eq(image.image_file_content_type)
              end

              it 'has image size' do
                expect(result['size']).to eq(image.image_file_file_size)
              end

              it 'has a download URL' do
                expect(result['image_file_url']).to eq("#{request.base_url}#{image.image_file.url}")
              end

              # xit "has a last modified time" do
              #   expect(result["last_modified"]).to eq(image.updated_at)
              # end

              it 'has alternative versions' do
                expect(result['alternatives']).to be_truthy
              end

              describe 'alternative versions' do
                let(:alternatives) { result['alternatives'] }

                it 'contains a medium version' do
                  expect(alternatives['medium']).to be_truthy
                end

                describe 'medium version' do
                  let(:alternative) { alternatives['medium'] }

                  it 'has image width' do
                    expect(alternative['width']).to eq(image.image_file.width(:medium))
                  end

                  it 'has image height' do
                    expect(alternative['height']).to eq(image.image_file.height(:medium))
                  end

                  it 'has image size' do
                    expect(alternative['size']).to eq(image.image_file.size(:medium))
                  end

                  it 'has a download URL' do
                    expect(alternative['image_file_url']).to eq("#{request.base_url}#{image.image_file.url(:medium)}")
                  end
                end

                describe 'thumb version' do
                  let(:alternative) { alternatives['thumb'] }

                  it 'has image width' do
                    expect(alternative['width']).to eq(image.image_file.width(:thumb))
                  end

                  it 'has image height' do
                    expect(alternative['height']).to eq(image.image_file.height(:thumb))
                  end

                  it 'has image size' do
                    expect(alternative['size']).to eq(image.image_file.size(:thumb))
                  end

                  it 'has a download URL' do
                    expect(alternative['image_file_url']).to eq("#{request.base_url}#{image.image_file.url(:thumb)}")
                  end
                end

              end
            end
          end

        end

        context 'invalid image' do
          before { get :show, params: {id: -1, format: :json}, session: valid_session }

          it 'returns an unsuccessful JSON response' do
            # rubocop:disable Style/StringHashKeys
            expect(JSON.parse(response.body)).to eq({'success' => false})
          end
        end

      end
    end

    describe 'GET new' do
      it 'assigns a new image as @image' do
        get :new, params: {}, session: valid_session
        expect(assigns(:image)).to be_a_new(Image)
      end
    end

    describe 'GET edit' do
      it 'assigns the requested image as @image' do
        image = Image.create! valid_attributes
        get :edit, params: {id: image.to_param}, session: valid_session
        expect(assigns(:image)).to eq(image)
      end
    end

    describe 'POST create' do
      describe 'with valid params' do
        it 'creates a new Image' do
          expect {
            post :create, params: {image: valid_attributes}, session: valid_session
          }.to change(Image, :count).by(1)
        end

        it 'assigns a newly created image as @image' do
          post :create, params: {image: valid_attributes}, session: valid_session
          expect(assigns(:image)).to be_a(Image)
          expect(assigns(:image)).to be_persisted
        end

        it 'redirects to the created image' do
          post :create, params: {image: valid_attributes}, session: valid_session
          expect(response).to redirect_to(Image.last)
        end
      end

      describe 'with invalid params' do
        it 'assigns a newly created but unsaved image as @image' do
          post :create, params: {image: invalid_attributes}, session: valid_session
          expect(assigns(:image)).to be_a_new(Image)
        end

        it "re-renders the 'new' template" do
          post :create, params: {image: invalid_attributes}, session: valid_session
          expect(response).to render_template('new')
        end
      end
    end

    describe 'PUT update' do
      describe 'with valid params' do
        # let(:new_attributes) {
        #   skip("Add a hash of attributes valid for your model")
        # }

        it 'updates the requested image' do
          image = Image.create! valid_attributes
          put :update, params: {id: image.to_param, image: {image_file: Rack::Test::UploadedFile.new((Rails.root + 'spec/files/images/Samsung_Phone.jpg'), 'image/jpg')}}, session: valid_session
          image.reload
          expect(image.user_file_name).to eq('Samsung_Phone.jpg')
        end

        it 'assigns the requested image as @image' do
          image = Image.create! valid_attributes
          put :update, params: {id: image.to_param, image: valid_attributes}, session: valid_session
          expect(assigns(:image)).to eq(image)
        end

        it 'redirects to the image' do
          image = Image.create! valid_attributes
          put :update, params: {id: image.to_param, image: valid_attributes}, session: valid_session
          expect(response).to redirect_to(image)
        end
      end

      describe 'with invalid params' do
        it 'assigns the image as @image' do
          image = Image.create! valid_attributes
          allow_any_instance_of(Image).to receive(:save).and_return(false)
          put :update, params: {id: image.to_param, image: invalid_attributes}, session: valid_session
          expect(assigns(:image)).to eq(image)
        end

        it "re-renders the 'edit' template" do
          image = Image.create! valid_attributes
          allow_any_instance_of(Image).to receive(:save).and_return(false)
          put :update, params: {id: image.to_param, image: invalid_attributes}, session: valid_session
          expect(response).to render_template('edit')
        end
      end
    end

    describe 'DELETE destroy' do
      it 'destroys the requested image' do
        image = Image.create! valid_attributes
        expect {
          delete :destroy, params: {id: image.to_param}, session: valid_session
        }.to change(Image, :count).by(-1)
      end

      it 'redirects to the images list' do
        image = Image.create! valid_attributes
        delete :destroy, params: {id: image.to_param}, session: valid_session
        expect(response).to redirect_to(images_url)
      end
    end
  end

  context 'not signed in' do
    describe 'with invalid params' do
      it 'handles stray netbot input' do
        put(:update, params: {'id' => 'test_put_qualysIaCUrw7f'})
        expect(response.response_code).to eq(302)
      end
    end
  end
  # rubocop:enable Style/StringHashKeys
end
