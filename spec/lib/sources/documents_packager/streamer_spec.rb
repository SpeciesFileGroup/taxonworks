require 'rails_helper'

describe Sources::DocumentsPackager::Streamer, type: :model do

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

  specify 'streams documents into the zip' do
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
    document_a = source_a.documents.first
    document_b = source_b.documents.first
    streamer = described_class.new

    zip = FakeZip.new
    streamer.stream(entries: [document_a, document_b], zip_streamer: ->(&block) { block.call(zip) })

    expected_a = Zaru::sanitize!(document_a.document_file_file_name)
    expected_b = Zaru::sanitize!(document_b.document_file_file_name)
    expect(zip.entries.length).to eq(2)
    expect(zip.entries.map { |entry| entry[:name] }).to contain_exactly(expected_a, expected_b)
    expect(zip.entries.all? { |entry| entry[:size] > 0 }).to be(true)
  end

  specify 'reports available when local file exists' do
    source = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 1.megabyte,
      filename: 'c.pdf',
      pages: 3
    )
    document = source.documents.first
    streamer = described_class.new

    expect(streamer.document_source_available?(document)).to be(true)
  end

  specify 'disambiguates duplicate filenames' do
    source_a = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 1.megabyte,
      filename: 'shared.pdf',
      pages: 1
    )
    # Same filename, different documents (by pages).
    source_b = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 1.megabyte,
      filename: 'shared.pdf',
      pages: 2
    )
    document_a = source_a.documents.first
    document_b = source_b.documents.first
    streamer = described_class.new

    zip = FakeZip.new
    streamer.stream(entries: [document_a, document_b], zip_streamer: ->(&block) { block.call(zip) })

    names = zip.entries.map { |entry| entry[:name] }
    base_name = Zaru::sanitize!(document_a.document_file_file_name)
    expect(names.uniq.length).to eq(2)
    expect(names).to include(base_name)
    # Disambiguation is to add `-<id>` to the common name.
    expect(names.find { |name| name != base_name }).to match(/\Ashared-\d+\.pdf\z/)
  end

  specify 'writes errors.txt when no documents could be streamed' do
    source = FactoryBot.create(
      :source_bibtex_with_document,
      size_bytes: 1.megabyte,
      filename: 'missing.pdf',
      pages: 4
    )
    document = source.documents.first

    # Remove the file so streaming fails.
    FileUtils.rm_f(document.document_file.path)

    streamer = described_class.new
    zip = FakeZip.new
    streamer.stream(entries: [document], zip_streamer: ->(&block) { block.call(zip) })

    expect(zip.entries.length).to eq(1)
    expect(zip.entries.first[:name]).to eq('errors.txt')
    expect(zip.entries.first[:size]).to be > 0
  end
end
