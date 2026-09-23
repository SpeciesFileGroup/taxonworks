require 'rails_helper'

describe Queries::AssertedEnvironment::Autocomplete, type: :model do
  let(:other_project) { FactoryBot.create(:valid_project, name: 'other') }

  specify 'by uri_label, partially' do
    a = FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')
    FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00000111', uri_label: 'xeric shrubland biome')

    query = Queries::AssertedEnvironment::Autocomplete.new('forest', project_id: a.project_id)
    expect(query.autocomplete.map(&:id)).to contain_exactly(a.id)
  end

  specify 'by uri, exact' do
    a = FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')

    query = Queries::AssertedEnvironment::Autocomplete.new(a.uri, project_id: a.project_id)
    expect(query.autocomplete.map(&:id)).to contain_exactly(a.id)
  end

  specify 'by uri, ends with' do
    a = FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')

    query = Queries::AssertedEnvironment::Autocomplete.new('ENVO_00002007', project_id: a.project_id)
    expect(query.autocomplete.map(&:id)).to contain_exactly(a.id)
  end

  specify 'no match' do
    query = Queries::AssertedEnvironment::Autocomplete.new('zzz')
    expect(query.autocomplete).to be_empty
  end

  specify '#id, #project_id' do
    a = FactoryBot.create(:valid_asserted_environment)
    FactoryBot.create(:valid_asserted_environment, project: other_project) # not this one

    q = Queries::AssertedEnvironment::Autocomplete.new(a.id.to_s, project_id: a.project_id)
    expect(q.autocomplete).to contain_exactly(a)
  end

  specify 'is scoped to project_id' do
    a = FactoryBot.create(:valid_asserted_environment, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')
    FactoryBot.create(:valid_asserted_environment, project: other_project, uri: 'http://purl.obolibrary.org/obo/ENVO_00002007', uri_label: 'temperate forest biome')

    query = Queries::AssertedEnvironment::Autocomplete.new('forest', project_id: a.project_id)
    expect(query.autocomplete.map(&:id)).to contain_exactly(a.id)
  end

  # Matching through the object's own label - delegates to that object's own
  # Autocomplete class (Queries::CollectingEvent::Autocomplete,
  # Queries::Otu::Autocomplete, Queries::Gazetteer::Autocomplete), so this
  # picks up whatever those already match on, not a hand-rolled subset.
  specify 'matches by Otu#name, via Queries::Otu::Autocomplete' do
    otu = FactoryBot.create(:valid_otu, name: 'Uniquotu name Foo')
    ae = FactoryBot.create(:asserted_environment, uri_label: 'planned burn', asserted_environment_object: otu)

    r = described_class.new('Uniquotu', project_id: ae.project_id).autocomplete
    expect(r).to include(ae)
  end

  specify 'matches by Otu taxon_name, via Queries::Otu::Autocomplete' do
    tn = FactoryBot.create(:relationship_species, name: 'uniquespecialis')
    otu = FactoryBot.create(:valid_otu, taxon_name: tn, name: nil)
    ae = FactoryBot.create(:asserted_environment, uri_label: 'planned burn', asserted_environment_object: otu)

    r = described_class.new('uniquespecialis', project_id: ae.project_id).autocomplete
    expect(r).to include(ae)
  end

  specify 'matches by Gazetteer#name, via Queries::Gazetteer::Autocomplete' do
    gaz = FactoryBot.create(:valid_gazetteer, name: 'Uniquegaz Land')
    ae = FactoryBot.create(:asserted_environment, uri_label: 'planned burn', asserted_environment_object: gaz)

    r = described_class.new('Uniquegaz', project_id: ae.project_id).autocomplete
    expect(r).to include(ae)
  end

  specify 'matches by CollectingEvent, via Queries::CollectingEvent::Autocomplete' do
    ce = FactoryBot.create(:valid_collecting_event, verbatim_locality: 'Zzyzx Preserve')
    ae = FactoryBot.create(:asserted_environment, uri_label: 'planned burn', asserted_environment_object: ce)

    r = described_class.new('Zzyzx', project_id: ae.project_id).autocomplete
    expect(r).to include(ae)
  end
end
