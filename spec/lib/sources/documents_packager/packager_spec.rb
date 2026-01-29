require 'rails_helper'

describe Sources::DocumentsPackager::Packager, type: :model do
  let(:project) { Project.find(1) }

  specify 'builds grouped preview data for selected sources' do
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

    packager = described_class.new(
      query_params: { source_id: [source_a.id, source_b.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 1.megabyte)

    expect(preview[:total_documents]).to eq(2)
    expect(preview[:groups].length).to eq(2)
    expect(preview[:sources].map { |s| s[:id] }).to contain_exactly(source_a.id, source_b.id)
  end

  specify 'splits documents into multiple groups when size exceeds max' do
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

    packager = described_class.new(
      query_params: { source_id: [source_a.id, source_b.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 1.5.megabytes)

    expect(preview[:groups].length).to eq(2)
  end

  specify 'includes a file larger than max in a group' do
    source = FactoryBot.create(
      :source_bibtex_with_document,
      project: project,
      size_bytes: 2.megabytes,
      filename: 'big.pdf',
      pages: 1
    )

    packager = described_class.new(
      query_params: { source_id: [source.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 1.megabytes)

    expect(preview[:groups].length).to eq(1)
    expect(preview[:groups].first[:document_ids]).to include(source.documents.first.id)
  end

  specify 'deduplicates documents linked to multiple sources' do
    source_a = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 1.megabyte,
      filename: 'shared.pdf',
      pages: 1
    )
    document = source_a.documents.first

    # Create second source and link it to the same document.
    source_b = FactoryBot.create(:valid_source_bibtex)
    ProjectSource.create!(
      project_id: project.id,
      source_id: source_b.id
    )
    Documentation.create!(
      project_id: project.id,
      documentation_object: source_b,
      document: document
    )

    packager = described_class.new(
      query_params: { source_id: [source_a.id, source_b.id] },
      project_id: project.id
    )

    preview = packager.preview(max_bytes: 10.megabytes)

    # Document appears in both sources' serialized data.
    expect(preview[:sources].length).to eq(2)
    expect(preview[:sources].all? { |s| s[:documents].length == 1 }).to be(true)

    # But only counted once in total and in groups.
    expect(preview[:total_documents]).to eq(1)
    expect(preview[:groups].length).to eq(1)
    expect(preview[:groups].first[:document_ids]).to eq([document.id])
  end
end
