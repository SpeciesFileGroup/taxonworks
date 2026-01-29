require 'rails_helper'

describe Export::Packagers::Documents, type: :model do
  let(:project) { Project.find(1) }

  class FakeZip
    attr_reader :files

    def initialize
      @files = {}
    end

    def write_deflated_file(name)
      sink = StringIO.new
      yield sink
      @files[name] = sink.string
    end
  end

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

  specify '#file_available? returns true when file exists' do
    source = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 1.megabyte,
      filename: 'test.pdf',
      pages: 1
    )
    document = source.documents.first

    packager = described_class.new(
      query_params: { source_id: [source.id] },
      project_id: project.id
    )

    expect(packager.file_available?(document)).to be(true)
  end

  context 'with unavailable files' do
    specify 'group size only counts available files' do
      source_a = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 1.megabyte,
        filename: 'available.pdf',
        pages: 1
      )
      source_b = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 2.megabytes,
        filename: 'unavailable.pdf',
        pages: 2
      )

      packager = described_class.new(
        query_params: { source_id: [source_a.id, source_b.id] },
        project_id: project.id
      )

      # Make second document unavailable by stubbing file existence
      doc_b = source_b.documents.first
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(doc_b.document_file.path).and_return(false)

      preview = packager.preview(max_bytes: 10.megabytes)

      # Both documents should be in the group
      expect(preview[:groups].first[:document_ids].length).to eq(2)

      # But size should only count the available document (1 MB)
      expect(preview[:groups].first[:size]).to eq(1.megabyte)

      # available_count should be 1
      expect(preview[:groups].first[:available_count]).to eq(1)
    end

    specify 'marks documents as unavailable in serialized data' do
      source = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 1.megabyte,
        filename: 'missing.pdf',
        pages: 1
      )

      packager = described_class.new(
        query_params: { source_id: [source.id] },
        project_id: project.id
      )

      document = source.documents.first
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(document.document_file.path).and_return(false)

      preview = packager.preview(max_bytes: 10.megabytes)

      doc_data = preview[:sources].first[:documents].first
      expect(doc_data[:available]).to be(false)
    end

    specify 'unavailable files do not cause premature group splits' do
      # Create 3 sources with documents
      source_a = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 1.megabyte,
        filename: 'a.pdf',
        pages: 1
      )
      source_b = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 1.megabyte,
        filename: 'b.pdf',
        pages: 2
      )
      source_c = FactoryBot.create(
        :source_bibtex_with_document,
        size_bytes: 1.megabyte,
        filename: 'c.pdf',
        pages: 3
      )

      packager = described_class.new(
        query_params: { source_id: [source_a.id, source_b.id, source_c.id] },
        project_id: project.id
      )

      # Make first two documents unavailable
      doc_a = source_a.documents.first
      doc_b = source_b.documents.first
      allow(File).to receive(:exist?).and_call_original
      allow(File).to receive(:exist?).with(doc_a.document_file.path).and_return(false)
      allow(File).to receive(:exist?).with(doc_b.document_file.path).and_return(false)

      # With 1.5 MB limit and 3x 1MB docs that count full size, we'd get 2 groups
      # But with unavailable docs counting as 0, all 3 should fit in 1 group
      preview = packager.preview(max_bytes: 1.5.megabytes)

      expect(preview[:groups].length).to eq(1)
      expect(preview[:groups].first[:document_ids].length).to eq(3)
      expect(preview[:groups].first[:available_count]).to eq(1)
    end
  end

  specify 'writes a documents.tsv manifest with correct columns' do
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

    group = packager.groups(max_bytes: 10.megabytes).first
    zip = FakeZip.new

    packager.stream(entries: group, zip_streamer: ->(&block) { block.call(zip) })

    manifest = zip.files['documents.tsv']
    expect(manifest).to be_present

    lines = manifest.split("\n")
    expect(lines.first).to eq("source_id\tdocument_id\tzip_filename\tfile_size_bytes")

    expected_rows = group.map do |entry|
      document = entry[:document]
      source = entry[:source]
      [
        source.id.to_s,
        document.id.to_s,
        Zaru.sanitize!(document.document_file_file_name).to_s,
        document.document_file_file_size.to_i.to_s
      ].join("\t")
    end

    expect(lines.drop(1)).to eq(expected_rows)
  end

  specify 'disambiguates duplicate filenames in documents.tsv' do
    source_a = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 2.megabytes,
      filename: 'shared.pdf',
      pages: 1
    )
    source_b = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 2.megabytes,
      filename: 'shared.pdf',
      pages: 2
    )

    packager = described_class.new(
      query_params: { source_id: [source_a.id, source_b.id] },
      project_id: project.id
    )

    group = packager.groups(max_bytes: 10.megabytes).first
    zip = FakeZip.new

    packager.stream(entries: group, zip_streamer: ->(&block) { block.call(zip) })

    manifest = zip.files['documents.tsv']
    expect(manifest).to be_present

    lines = manifest.split("\n").drop(1)
    names = lines.map { |row| row.split("\t")[2] }

    document_a = source_a.documents.first
    document_b = source_b.documents.first

    expect(names).to eq(['shared.pdf', "shared-#{document_b.id}.pdf"])
  end
end
