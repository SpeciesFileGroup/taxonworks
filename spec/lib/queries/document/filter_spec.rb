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

  specify '#file_extension_group matches extension classes with a single extension' do
    query.file_extension_group = 'pdf'
    expect(Document.all.count).to eq(3)
    expect(query.all.map(&:id)).to eq([pdf_doc.id])
  end

  specify '#file_extension_group matches extension classes with multiple extensions' do
    query.file_extension_group = 'nexus'
    expect(Document.all.count).to eq(3)
    expect(query.all.order(updated_at: :desc).map(&:id)).to eq([nxs_doc.id, nex_doc.id])
  end

  specify '#file_extension_group with no matches returns nothing' do
    query.file_extension_group = 'asdffdsa'
    expect(query.all.count).to eq(0)
  end

  specify 'empty #file_extension_group matches all files' do
    query.file_extension_group = ''
    expect(query.all.count).to eq(3)
  end
end