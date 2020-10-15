require 'rails_helper'

describe Identifier::Global::Wikidata, type: :model, group: :identifiers do
  let(:id) { Identifier::Global::Wikidata.new }

  context 'looking for data', vcr: true do
    specify 'matches "namespace" 1' do
      id.identifier = 'Q9999999999999' # hmmm

      VCR.use_cassette('wikidata-1') do
        id.valid?
      end
      expect(id.errors.messages[:identifier]).to include("Can not find #{id.identifier} in wikidata.")
    end
  end

  specify 'matches "namespace" 1' do
    id.identifier = '--123'
    id.valid?
    expect(id.errors.messages[:identifier]).to_not be_empty
  end

  specify 'matches "namespace" 2' do
    id.identifier = 'Q123'
    id.valid?
    expect(id.errors.messages[:identifier]).to be_empty
  end

  specify 'matches "namespace" 3' do
    id.identifier = 'P123'
    id.valid?
    expect(id.errors.messages[:identifier]).to be_empty
  end

  specify 'matches "namespace" 3' do
    id.identifier = 'PR123'
    id.valid?
    expect(id.errors.messages[:identifier]).to_not be_empty
  end

  specify '#namespace_string' do
    id.identifier = 'P123'
    expect(id.namespace_string).to eq('P')
  end

  specify '#uri 1' do
    id.identifier = 'P123'
    expect(id.uri).to eq('http://www.wikidata.org/wiki/Property:P123')
  end

  specify '#uri 2' do
    id.identifier = 'Q123'
    expect(id.uri).to eq('http://www.wikidata.org/wiki/Q123')
  end

end
