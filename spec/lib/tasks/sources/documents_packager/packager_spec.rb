require 'rails_helper'

describe Sources::DocumentsPackager::Packager do
  let(:user) { FactoryBot.create(:valid_user) }
  let(:project) { FactoryBot.create(:valid_project, created_by_id: user.id, updated_by_id: user.id) }

  before do
    Current.user_id = user.id
    Current.project_id = project.id
    FactoryBot.create(:valid_project_member, user: user, project: project)
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

  it 'builds grouped preview data for selected sources' do
    source_a, = create_source_with_document(2.megabytes, filename: "a-#{SecureRandom.hex(4)}.pdf")
    source_b, = create_source_with_document(2.megabytes, filename: "b-#{SecureRandom.hex(4)}.pdf")

    packager = described_class.new(
      query_params: { source_id: [source_a.id, source_b.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 1.megabyte)

    expect(preview[:total_documents]).to eq(2)
    expect(preview[:groups].length).to eq(2)
    expect(preview[:sources].map { |s| s[:id] }).to contain_exactly(source_a.id, source_b.id)
  end
end
