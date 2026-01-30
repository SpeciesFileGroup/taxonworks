require 'rails_helper'

describe Tasks::Images::ImagesPackagerController, type: :controller do
  include ControllerSpecHelper

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  before do
    sign_in_user_and_select_project(user, project.id)
  end

  describe 'POST preview' do
    specify 'returns grouped images' do
      image_a = FactoryBot.create(:tiny_random_image)
      image_b = FactoryBot.create(:tiny_random_image)

      post :preview, params: { image_id: [image_a.id, image_b.id], max_mb: 50 }, format: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['images'].length).to eq(2)
      expect(body['groups'].length).to be >= 1
      expect(body['total_images']).to eq(2)
    end

    specify 'returns empty preview when no image_ids provided' do
      post :preview, params: { image_id: [] }, format: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['images']).to eq([])
      expect(body['groups']).to eq([])
      expect(body['total_images']).to eq(0)
    end
  end

  describe 'POST download' do
    specify 'sets a zip filename in the response headers' do
      image = FactoryBot.create(:tiny_random_image)

      post :download, params: { image_id: [image.id], group: 1, max_mb: 50 }

      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Disposition']).to include('TaxonWorks-images_download-')
    end

    specify 'returns 422 when no images queued' do
      post :download, params: { group: 1 }

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('No images queued.')
    end

    specify 'returns 404 when group index is invalid' do
      image = FactoryBot.create(:tiny_random_image)

      post :download, params: { image_id: [image.id], group: 999, max_mb: 50 }

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Group not found.')
    end
  end
end
