require 'rails_helper'

describe Queries::AssertedEnvironment::Filter, type: :model do

  let(:q) { Queries::AssertedEnvironment::Filter.new({}) }

  let!(:otu_environment) {
    FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')
  }

  let!(:collecting_event_environment) {
    FactoryBot.create(:valid_collecting_event_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00000111', uri_label: 'xeric shrubland biome')
  }

  specify '#asserted_environment_id' do
    q.asserted_environment_id = [otu_environment.id]
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id)
  end

  specify '#asserted_environment_object_type' do
    q.asserted_environment_object_type = ['CollectingEvent']
    expect(q.all.pluck(:id)).to contain_exactly(collecting_event_environment.id)
  end

  specify '#asserted_environment_object_type and #asserted_environment_object_id' do
    q.asserted_environment_object_type = ['Otu']
    q.asserted_environment_object_id = [otu_environment.asserted_environment_object_id]
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id)
  end

  specify '#asserted_environment_object_id alone (ambiguous type) does not filter' do
    q.asserted_environment_object_id = [otu_environment.asserted_environment_object_id]
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id, collecting_event_environment.id)
  end

  specify '#uri, partial' do
    q.uri = 'ENVO_00002007'
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id)
  end

  specify '#uri, exact' do
    q.uri = otu_environment.uri
    q.uri_exact = true
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id)
  end

  specify '#uri_label, partial' do
    q.uri_label = 'forest'
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id)
  end

  specify '#uri_label, exact excludes a partial match' do
    q.uri_label = 'forest'
    q.uri_label_exact = true
    expect(q.all.pluck(:id)).to be_empty
  end

  specify '#notes facet (via Queries::Concerns::Notes)' do
    FactoryBot.create(:valid_note, note_object: otu_environment)
    q.notes = true
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id)
  end

  specify '#otu_query_facet' do
    q = Queries::AssertedEnvironment::Filter.new(
      otu_query: {otu_id: otu_environment.asserted_environment_object_id}
    )
    expect(q.all.pluck(:id)).to contain_exactly(otu_environment.id)
  end

  specify '#collecting_event_query_facet' do
    q = Queries::AssertedEnvironment::Filter.new(
      collecting_event_query: {
        collecting_event_id: collecting_event_environment.asserted_environment_object_id
      }
    )
    expect(q.all.pluck(:id)).to contain_exactly(collecting_event_environment.id)
  end

end
