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


end