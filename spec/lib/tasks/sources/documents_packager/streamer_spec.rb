require 'rails_helper'

describe Sources::DocumentsPackager::Streamer do
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

  class FakeZip
    attr_reader :entries

    def initialize
      @entries = []
    end

    def write_deflated_file(name)
      sink = StringIO.new
      yield sink
      @entries << { name: name, size: sink.string.bytesize }
    end
  end

  it 'streams documents into the zip and marks availability' do
    _, document = create_source_with_document(1.megabyte, filename: "c-#{SecureRandom.hex(4)}.pdf")
    streamer = described_class.new

    expect(streamer.document_source_available?(document)).to be(true)

    zip = FakeZip.new
    streamer.stream(entries: [document], zip_streamer: ->(&block) { block.call(zip) })

    expect(zip.entries.length).to eq(1)
    expected_name = Zaru::sanitize!(document.document_file_file_name)
    expect(zip.entries.first[:name]).to eq(expected_name)
    expect(zip.entries.first[:size]).to be > 0
  end

  it 'disambiguates duplicate filenames' do
    _, document_a = create_source_with_document(1.megabyte, filename: 'shared.pdf')
    _, document_b = create_source_with_document(1.megabyte, filename: 'shared.pdf')
    streamer = described_class.new

    zip = FakeZip.new
    streamer.stream(entries: [document_a, document_b], zip_streamer: ->(&block) { block.call(zip) })

    names = zip.entries.map { |entry| entry[:name] }
    expect(names.uniq.length).to eq(2)
    expect(names.first).to eq(Zaru::sanitize!(document_a.document_file_file_name))
  end
end
