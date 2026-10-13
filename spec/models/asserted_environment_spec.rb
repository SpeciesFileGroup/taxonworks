require 'rails_helper'

describe AssertedEnvironment, type: :model, group: :shared_geo do
  include ActiveJob::TestHelper

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

  context '.batch_by_filter_scope' do
    let(:otu2) { FactoryBot.create(:valid_otu) }
    let(:source) { FactoryBot.create(:valid_source) }
    let(:otu_filter_query) {
      { 'otu_query' => Queries::Otu::Filter.new(otu_id: [otu.id, otu2.id]).params }
    }
    let(:environment_params) { { uri: envo_uri, uri_label: 'temperate forest biome' } }

    specify ':add creates an asserted environment for each OTU' do
      r = AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params
      )

      expect(r[:updated].length).to eq(2)
      expect(r[:not_updated]).to be_empty
      expect(AssertedEnvironment.all.map(&:asserted_environment_object))
        .to contain_exactly(otu, otu2)
      expect(AssertedEnvironment.pluck(:uri).uniq).to eq([envo_uri])
    end

    specify ':add creates an asserted environment for each collecting event' do
      ce2 = FactoryBot.create(:valid_collecting_event)
      q = Queries::CollectingEvent::Filter.new(collecting_event_id: [collecting_event.id, ce2.id])

      AssertedEnvironment.batch_by_filter_scope(
        filter_query: { 'collecting_event_query' => q.params },
        mode: :add,
        params: environment_params
      )

      expect(AssertedEnvironment.all.map(&:asserted_environment_object))
        .to contain_exactly(collecting_event, ce2)
    end

    specify ':add appends after existing asserted environments on the object' do
      FactoryBot.create(:valid_asserted_environment, asserted_environment_object: otu)

      AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params
      )

      expect(AssertedEnvironment.find_by(asserted_environment_object: otu, uri: envo_uri).position).to eq(2)
    end

    specify ':add adds a citation to each new asserted environment' do
      AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params.merge(citation: { source_id: source.id, pages: '12' })
      )

      expect(Citation.where(citation_object_type: 'AssertedEnvironment').count).to eq(2)
      expect(Citation.pluck(:pages).uniq).to eq(['12'])
    end

    specify ':add with string-keyed citation params (as from the controller)' do
      AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params.merge(citation: { 'source_id' => source.id.to_s })
      )

      expect(Citation.where(citation_object_type: 'AssertedEnvironment').count).to eq(2)
    end

    specify ':add adds the citation to an already existing asserted environment' do
      existing = FactoryBot.create(:valid_asserted_environment,
        asserted_environment_object: otu, uri: envo_uri, uri_label: 'temperate forest biome')

      r = AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params.merge(citation: { source_id: source.id })
      )

      expect(r[:updated]).to include(existing.id)
      expect(r[:updated].length).to eq(2)
      expect(AssertedEnvironment.count).to eq(2)
      expect(existing.citations.count).to eq(1)
    end

    specify ':add reports an already existing asserted environment, without citation, as not updated' do
      FactoryBot.create(:valid_asserted_environment,
        asserted_environment_object: otu, uri: envo_uri, uri_label: 'temperate forest biome')

      r = AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params
      )

      expect(r[:updated].length).to eq(1)
      expect(r[:not_updated]).to contain_exactly(otu.id)
      expect(r[:validation_errors].keys).to include(a_string_matching(/already exists/))
      expect(AssertedEnvironment.count).to eq(2)
    end

    specify ':add reports an already cited existing asserted environment as not updated' do
      existing = FactoryBot.create(:valid_asserted_environment,
        asserted_environment_object: otu, uri: envo_uri, uri_label: 'temperate forest biome',
        citations_attributes: [{ source_id: source.id }])

      r = AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params.merge(citation: { source_id: source.id })
      )

      expect(r[:not_updated]).to contain_exactly(otu.id)
      expect(existing.citations.count).to eq(1)
    end

    specify ':add with an invalid uri creates nothing' do
      r = AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: { uri: 'http://purl.obolibrary.org/obo/UBERON_0000979', uri_label: 'leg' }
      )

      expect(r[:not_updated]).to contain_exactly(otu.id, otu2.id)
      expect(r[:validation_errors].keys).to include(a_string_matching(/ENVO/))
      expect(AssertedEnvironment.count).to eq(0)
    end

    specify ':add on a filter of a type that can not have asserted environments errors' do
      source
      r = AssertedEnvironment.batch_by_filter_scope(
        filter_query: { 'source_query' => Queries::Source::Filter.new(source_id: [source.id]).params },
        mode: :add,
        params: environment_params
      )

      expect(r[:errors]).not_to be_empty
      expect(AssertedEnvironment.count).to eq(0)
    end

    specify ':add without uri errors' do
      r = AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: { uri_label: 'temperate forest biome' }
      )

      expect(r[:errors]).not_to be_empty
      expect(AssertedEnvironment.count).to eq(0)
    end

    specify ':add, async' do
      AssertedEnvironment.batch_by_filter_scope(
        filter_query: otu_filter_query,
        mode: :add,
        params: environment_params.merge(citation: { source_id: source.id }),
        project_id: Project.first.id,
        user_id: User.first.id,
        async_cutoff: 0
      )
      expect(AssertedEnvironment.count).to eq(0)

      perform_enqueued_jobs

      expect(AssertedEnvironment.all.map(&:asserted_environment_object))
        .to contain_exactly(otu, otu2)
      expect(Citation.where(citation_object_type: 'AssertedEnvironment').count).to eq(2)
    end
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
