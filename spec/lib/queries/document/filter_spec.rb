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
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
      Spec::Support::Utilities::Files.generate_pdf(pages:1),
      'application/pdf'
      )
    )
  }

  specify '#file_extension_group_name matches extension classes with a single extension' do
    query.file_extension_group_name = 'pdf'
    expect(Document.all.count).to eq(3)
    expect(query.all.map(&:id)).to eq([pdf_doc.id])
  end

  specify '#file_extension_group_name matches extension classes with multiple extensions' do
    query.file_extension_group_name = 'nexus'
    expect(Document.all.count).to eq(3)
    expect(query.all.map(&:id)).to contain_exactly(nxs_doc.id, nex_doc.id)
  end

  specify '#file_extension_group_name with no matches returns nothing' do
    query.file_extension_group_name = 'asdffdsa'
    expect(query.all.count).to eq(0)
  end

  specify 'empty #file_extension_group_name matches all files' do
    query.file_extension_group_name = ''
    expect(query.all.count).to eq(3)
  end
end