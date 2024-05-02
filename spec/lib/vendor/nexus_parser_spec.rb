require 'rails_helper'

RSpec.describe Vendor::NexusParser, type: :model, group: :observation_matrix do
  let(:doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/small_with_species.nex'),
        'text/plain'
      ))
  }

  let(:invalid_doc) {
    Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/malformed.nex'),
        'text/plain'
      ))
  }

  specify 'parsed valid nexus file has data' do
    nf = Vendor::NexusParser.document_to_nexus(doc)

    expect(nf.taxa.size).to eq(2)
    expect(nf.characters.size).to eq(3)
    expect(nf.codings.size).to eq(2)
  end

  specify 'nexus doc can be loaded by doc id' do
    nf = Vendor::NexusParser.document_id_to_nexus(doc.id)

    expect(nf.class).to eq(NexusParser::NexusParser)
  end


  specify 'invalid nexus file raises NexusParser::ParseError' do
    expect {Vendor::NexusParser.document_to_nexus(invalid_doc)}.to raise_error NexusParser::ParseError
  end

  specify 'invalid doc id raises ActiveRecord::RecordNotFound' do
    expect {Vendor::NexusParser.document_id_to_nexus(1234)}.to raise_error ActiveRecord::RecordNotFound
  end

  specify 'imported data names gap states' do
    nf = Vendor::NexusParser.document_to_nexus(doc)

    expect(nf.characters[0].states['-'].name).to eq('gap')
  end

  specify "gap state + character state with name 'gap' raises" do
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/gap_state_and_character_name.nxs'),
        'text/plain'
      ))

    expect{ Vendor::NexusParser.document_to_nexus(d) }.to raise_error TaxonWorks::Error
  end

  specify 'character with duplicate state name raises' do
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/repeated_character_state_name.nex'),
        'text/plain'
      ))

    expect{Vendor::NexusParser.document_to_nexus(d)}.to raise_error TaxonWorks::Error
  end

  specify 'character with empty name raises' do
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/empty_character_name.nex'),
        'text/plain'
      ))

    expect{Vendor::NexusParser.document_to_nexus(d)}.to raise_error TaxonWorks::Error
  end

  specify 'character state with empty name raises' do
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/empty_character_state_name.nex'),
        'text/plain'
      ))

    expect{Vendor::NexusParser.document_to_nexus(d)}.to raise_error TaxonWorks::Error
  end

end