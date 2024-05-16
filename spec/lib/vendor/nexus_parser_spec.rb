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

  let(:unsquished_doc) {}

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

    # 1 head / gap pointy
    # 0?2
	  # -01
    expect{ Vendor::NexusParser.document_to_nexus(d) }.to raise_error TaxonWorks::Error
  end

  specify 'character with duplicate state name raises' do
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + 'spec/files/nexus/repeated_character_state_name.nex'),
        'text/plain'
      ))

    # 2 foot / toey toey # repeated character state name
    expect{Vendor::NexusParser.document_to_nexus(d)}.to raise_error TaxonWorks::Error
  end

  specify 'character with empty name gets a name assigned' do
    file_name = 'empty_character_name.nex'
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + "spec/files/nexus/#{file_name}"),
        'text/plain'
      ))

    nf = Vendor::NexusParser.document_to_nexus(d)

    #  2 / toey heely # no character name
    expect(nf.characters.second.name).to eq("Undefined (2) from [#{file_name}]")
  end

  specify 'character state with empty name gets a name assigned' do
    file_name = 'empty_character_state_name.nex'
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + "spec/files/nexus/#{file_name}"),
        'text/plain'
      ))

    nf = Vendor::NexusParser.document_to_nexus(d)

    # ... 3 ribs / spherical monodromic; # only two defined states
    #
    # 0?3 # state label 3
	  # -01
    expect(nf.characters.third.states['3'].name).to eq("Undefined (3) from [#{file_name}]")
  end

  specify 'ghost character is assigned defaults' do
    file_name = 'ghost_character.nex'
    d = Document.create!(
      document_file: Rack::Test::UploadedFile.new(
        (Rails.root + "spec/files/nexus/#{file_name}"),
        'text/plain'
      ))

    nf = Vendor::NexusParser.document_to_nexus(d)

    # 1 head / round pointy, 3 ribs / spherical monodromic; # ghost character 2
	  # 01?
	  # -01
    expect(nf.characters.second.name).to eq("Undefined (2) from [#{file_name}]")

    expect(nf.characters.second.states['1'].name).to eq("Undefined (1) from [#{file_name}]")

    expect(nf.characters.second.states['0'].name).to eq("Undefined (0) from [#{file_name}]")
  end

  context 'with unsquished nexus names' do
    let!(:unsquished_doc) {
      Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/nexus/unsquished_names.nex'),
          'text/plain'
        ))
    }

    let!(:nf) {
      Vendor::NexusParser.document_to_nexus(unsquished_doc)
    }

    specify 'unsquished taxon names get squished' do
      # ' Carabus    goryi  '
      expect(nf.taxa.first.name).to eq('Carabus goryi')
    end

    specify 'unsquished character names get squished' do
      # 1 /  square pointy, 2 'right  foot' / 'one,  purple ' ' one,  gree  n' ;
      expect(nf.characters.first.name).to eq('Undefined (1) from [unsquished_names.nex]')
      expect(nf.characters.second.name).to eq('right foot')
      expect(nf.characters.third.name).to eq('Undefined (3) from [unsquished_names.nex]')
    end

    specify 'unsquished state names get squished' do
      # 1 /  square pointy, 2 'right  foot' / 'one,  purple ' ' one,  gree  n' ;
      # MATRIX
	    # ' Carabus    goryi'     -(0 1)3
      expect(nf.characters.first.states['-'].name).to eq('gap')

      expect(nf.characters.second.states['0'].name).to eq('one, purple')
      expect(nf.characters.second.states['1'].name).to eq('one, gree n')

      expect(nf.characters.third.states['3'].name).to eq('Undefined (3) from [unsquished_names.nex]')
    end
  end
end