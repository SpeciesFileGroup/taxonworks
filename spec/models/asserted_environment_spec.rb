require 'rails_helper'

describe AssertedEnvironment, type: :model, group: :shared_geo do
  let(:asserted_environment) { AssertedEnvironment.new }
  let(:otu) { FactoryBot.create(:valid_otu) }
  let(:collecting_event) { FactoryBot.create(:valid_collecting_event) }
  let(:gazetteer) { FactoryBot.create(:valid_gazetteer) }

  let(:envo_uri) { 'http://purl.obolibrary.org/obo/ENVO_00002007' }

  specify '#asserted_environment_object is required' do
    asserted_environment.valid?
    expect(asserted_environment.errors.include?(:asserted_environment_object)).to be_truthy
  end

  specify '#uri is required' do
    asserted_environment.asserted_environment_object = otu
    asserted_environment.uri_label = 'temperate forest biome'
    asserted_environment.valid?
    expect(asserted_environment.errors.include?(:uri)).to be_truthy
  end

  specify '#uri_label is required' do
    asserted_environment.asserted_environment_object = otu
    asserted_environment.uri = envo_uri
    asserted_environment.valid?
    expect(asserted_environment.errors.include?(:uri_label)).to be_truthy
  end

  specify '#uri must be an ENVO term' do
    asserted_environment.asserted_environment_object = otu
    asserted_environment.uri = 'http://purl.obolibrary.org/obo/UBERON_0000979'
    asserted_environment.uri_label = 'leg'
    asserted_environment.valid?
    expect(asserted_environment.errors.include?(:uri)).to be_truthy
  end

  specify '#uri as a valid ENVO term is valid' do
    asserted_environment.asserted_environment_object = otu
    asserted_environment.uri = envo_uri
    asserted_environment.uri_label = 'temperate forest biome'
    expect(asserted_environment.valid?).to be_truthy
  end

  specify 'is valid for an OTU object' do
    a = FactoryBot.build(:valid_asserted_environment)
    expect(a.valid?).to be_truthy
  end

  specify 'is valid for a CollectingEvent object' do
    a = FactoryBot.build(:valid_collecting_event_asserted_environment)
    expect(a.valid?).to be_truthy
  end

  specify 'is valid for a Gazetteer object' do
    a = FactoryBot.build(:valid_gazetteer_asserted_environment)
    expect(a.valid?).to be_truthy
  end

  specify 'is not valid for a disallowed object type' do
    source = FactoryBot.create(:valid_source)
    a = AssertedEnvironment.new(
      asserted_environment_object: source,
      uri: envo_uri,
      uri_label: 'temperate forest biome'
    )
    expect(a.valid?).to be_falsey
  end

  specify '#unique - the same ENVO term can not be asserted twice for the same object' do
    a = FactoryBot.create(:valid_asserted_environment, uri: envo_uri, uri_label: 'temperate forest biome')
    b = FactoryBot.build(:valid_asserted_environment, asserted_environment_object: a.asserted_environment_object, uri: envo_uri, uri_label: 'temperate forest biome')
    expect(b.valid?).to be_falsey
  end

  specify 'the same ENVO term can be asserted for two different objects' do
    a = FactoryBot.create(:valid_asserted_environment, uri: envo_uri, uri_label: 'temperate forest biome')
    b = FactoryBot.build(:valid_asserted_environment, uri: envo_uri, uri_label: 'temperate forest biome')
    expect(b.valid?).to be_truthy
  end

  specify 'a different ENVO term can be asserted for the same object' do
    a = FactoryBot.create(:valid_asserted_environment, uri: envo_uri, uri_label: 'temperate forest biome')
    b = FactoryBot.build(
      :valid_asserted_environment,
      asserted_environment_object: a.asserted_environment_object,
      uri: 'http://purl.obolibrary.org/obo/ENVO_00000111',
      uri_label: 'xeric shrubland biome'
    )
    expect(b.valid?).to be_truthy
  end

  specify '#cached is set from uri_label on save' do
    a = FactoryBot.create(:valid_asserted_environment, uri: envo_uri, uri_label: 'temperate forest biome')
    expect(a.reload.cached).to eq('temperate forest biome')
  end

  specify '#position defaults to the first position for a new object' do
    a = FactoryBot.create(:valid_asserted_environment)
    expect(a.position).to eq(1)
  end

  specify '#position orders multiple assertions on the same object' do
    a = FactoryBot.create(:valid_asserted_environment, uri: envo_uri, uri_label: 'temperate forest biome')
    b = FactoryBot.create(
      :valid_asserted_environment,
      asserted_environment_object: a.asserted_environment_object,
      uri: 'http://purl.obolibrary.org/obo/ENVO_00000111',
      uri_label: 'xeric shrubland biome'
    )
    expect(a.reload.position).to eq(1)
    expect(b.reload.position).to eq(2)
  end

  specify '#destroy' do
    a = FactoryBot.create(:valid_asserted_environment)
    expect(a.destroy).to be_truthy
  end

  context 'associations' do
    context 'belongs_to' do
      context 'object' do
        ENVIRONMENT_ASSERTABLE_TYPES.each do |t|
          specify "polymorphic for #{t} object" do
            a = AssertedEnvironment.new(asserted_environment_object: t.tableize.classify.constantize.new)
            expect(a.asserted_environment_object).to be_a(t.constantize)
          end
        end
      end
    end
  end
end
