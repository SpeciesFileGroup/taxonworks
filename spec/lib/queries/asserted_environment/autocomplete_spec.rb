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
end
