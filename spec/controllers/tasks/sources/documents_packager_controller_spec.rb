require 'rails_helper'

describe Tasks::Sources::DocumentsPackagerController, type: :controller do
  include ControllerSpecHelper

  let(:user) { User.find(1) }
  let(:project) { Project.find(1) }

  before do
    sign_in_user_and_select_project(user, project.id)
  end

  describe 'POST preview' do
    specify 'returns grouped documents with availability counts' do
      source_a = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 2.megabytes,
        filename: 'a.pdf',
        pages: 1
      )
      source_b = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 2.megabytes,
        filename: 'b.pdf',
        pages: 2
      )

      post :preview, params: { source_id: [source_a.id, source_b.id], max_mb: 1 }, format: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['groups'].length).to be >= 1

      first_source = body['sources'].find { |s| s['id'] == source_a.id }
      expect(first_source['documents'].first['group_index']).to eq(1)
    end

    specify 'returns empty preview when no source_ids provided' do
      post :preview, params: { source_id: [] }, format: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['sources']).to eq([])
      expect(body['groups']).to eq([])
      expect(body['total_documents']).to eq(0)
    end
  end

  describe 'POST download' do
    specify 'sets a zip filename in the response headers' do
      source = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 1.megabyte,
        filename: 'c.pdf',
        pages: 1
      )

      post :download, params: { source_id: [source.id], group: 1, max_mb: 50 }

      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Disposition']).to include('TaxonWorks-sources_download-')
    end

    specify 'returns 422 when no sources queued' do
      post :download, params: { group: 1 }

      expect(response).to have_http_status(:unprocessable_content)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('No sources queued.')
    end

    specify 'returns 404 when group index is invalid' do
      source = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 1.megabyte,
        filename: 'd.pdf',
        pages: 1
      )

      post :download, params: { source_id: [source.id], group: 999, max_mb: 50 }

      expect(response).to have_http_status(:not_found)
      body = JSON.parse(response.body)
      expect(body['error']).to eq('Group not found.')
    end
  end
end
