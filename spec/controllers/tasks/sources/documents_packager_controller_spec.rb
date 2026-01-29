require 'rails_helper'

describe Tasks::Sources::DocumentsPackagerController, type: :controller do
  include ControllerSpecHelper

  let(:user) { FactoryBot.create(:valid_user) }
  let(:project) { FactoryBot.create(:valid_project, created_by_id: user.id, updated_by_id: user.id) }

  before do
    Current.user_id = user.id
    Current.project_id = project.id
    FactoryBot.create(:valid_project_member, user: user, project: project)
    sign_in_user_and_select_project(user, project.id)
    @request.session[:project_id] = project.id
  end

  def create_source_with_document(size_bytes, filename: nil)
    source = FactoryBot.create(:valid_source_verbatim)
    ProjectSource.create!(
      project_id: project.id,
      source_id: source.id,
      created_by_id: user.id,
      updated_by_id: user.id
    )

    filename ||= "doc-#{SecureRandom.hex(4)}.pdf"
    document = FactoryBot.create(
      :document,
      project_id: project.id,
      document_file: Rack::Test::UploadedFile.new(
        Spec::Support::Utilities::Files.generate_pdf(
          pages: rand(1..3),
          file_name: filename
        ),
        'application/pdf'
      )
    )
    document.update_column(:document_file_file_size, size_bytes)

    Documentation.create!(
      project_id: project.id,
      documentation_object: source,
      document: document,
      created_by_id: user.id,
      updated_by_id: user.id
    )

    [source, document]
  end

  describe 'POST preview' do
    it 'returns grouped documents with availability counts' do
      source_a, = create_source_with_document(2.megabytes, filename: "a-#{SecureRandom.hex(4)}.pdf")
      source_b, = create_source_with_document(2.megabytes, filename: "b-#{SecureRandom.hex(4)}.pdf")

      post :preview, params: { source_id: [source_a.id, source_b.id], max_mb: 1 }, format: :json

      expect(response).to have_http_status(:ok)
      body = JSON.parse(response.body)

      expect(body['groups'].length).to be >= 1

      first_source = body['sources'].find { |s| s['id'] == source_a.id }
      expect(first_source['documents'].first['group_index']).to eq(1)
    end
  end

  describe 'POST download' do
    it 'sets a zip filename in the response headers' do
      source, = create_source_with_document(1.megabyte, filename: "c-#{SecureRandom.hex(4)}.pdf")

      post :download, params: { source_id: [source.id], group: 1, max_mb: 50 }

      expect(response).to have_http_status(:ok)
      expect(response.headers['Content-Disposition']).to include('TaxonWorks-download-')
    end
  end
end
