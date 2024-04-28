require 'rails_helper'

describe Queries::Source::Filter, type: :model, group: [:documents, :filter] do
  let!(:query) {  Queries::Document::Filter.new({})  }

  let!(:nex_doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/small_with_species.nex'),
        'text/plain'
      ))
  }

  let!(:nxs_doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/gap_state_and_character_name.nxs'),
        'text/plain'
      ))
  }

  let!(:pdf_doc) {
    FactoryBot.create(:valid_document)
  }

  specify '#file_extension matches a single extension' do
    query.file_extension = '.pdf'
    expect(Document.all.count).to eq(3)
    expect(query.all.map(&:id)).to eq([pdf_doc.id])
  end

  specify '#file_extension matches multi-extensions' do
    query.file_extension = '.nex, .nxs'
    expect(Document.all.count).to eq(3)
    expect(query.all.order(updated_at: :desc).map(&:id)).to eq([nxs_doc.id, nex_doc.id])
  end

  specify '#file_extension with no matches returns nothing' do
    query.file_extension = '.asdf'
    expect(query.all.count).to eq(0)
  end
end