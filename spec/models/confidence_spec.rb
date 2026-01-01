require 'rails_helper'

RSpec.describe Confidence, type: :model, group: :confidence do
  include ActiveJob::TestHelper

  let(:confidence) { Confidence.new }
  let(:confidence_level) { FactoryBot.create(:valid_confidence_level) }
  let(:specimen) { FactoryBot.create(:valid_specimen) }

  specify '#batch_by_filter_scope :replace, async, ' do
    c1 = FactoryBot.create(:valid_confidence_level)
    Confidence.create!(confidence_object: specimen, confidence_level:)

    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    p = ActionController::Parameters.new( { 'collection_object_query' => q.params })

    Confidence.batch_by_filter_scope(
      filter_query: p,
      mode: :replace,
      async_cutoff: 0,
      params: {
        confidence_level_id: c1.id,
        replace_confidence_level_id: confidence_level.id
      },
      project_id: Project.first.id,
      user_id: User.first.id
    )

    # expect { ConfidenceBatchJob.perform_later }.to have_enqueued_job.on_queue(:query_batch_update)
    perform_enqueued_jobs

    expect(Confidence.all.first.confidence_level_id).to eq(c1.id)
  end

  specify '#batch_by_filter_scope :replace, async' do
    c1 = FactoryBot.create(:valid_confidence_level)

    Confidence.create!(confidence_object: specimen, confidence_level:)

    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :replace,
      async_cutoff: 0,
      params: {
        confidence_level_id: c1.id,
        replace_confidence_level_id: confidence_level.id
      },
      project_id: Project.first.id,
      user_id: User.first.id
    )

    # expect { ConfidenceBatchJob.perform_later }.to have_enqueued_job.on_queue(:query_batch_update)
    perform_enqueued_jobs

    expect(Confidence.all.first.confidence_level_id).to eq(c1.id)
  end

  specify '#batch_by_filter_scope :replace' do
    c1 = FactoryBot.create(:valid_confidence_level)
    Confidence.create!(confidence_object: specimen, confidence_level:)
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :replace,
      params: {
        confidence_level_id: c1.id,
        replace_confidence_level_id: confidence_level.id
      }
    )
    expect(Confidence.all.first.confidence_level_id).to eq(c1.id)
  end

  # No async test, we don't use
  specify '#batch_by_filter_scope :remove' do
    Confidence.create!(confidence_object: specimen, confidence_level:)
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :remove,
      params: {
        confidence_level_id: confidence_level.id
      }
    )
    expect(Confidence.all.count).to eq(0)
  end

  specify '#batch_by_filter_scope :add' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :add,
      params: {
        confidence_level_id: confidence_level.id
      }
    )
    expect(Confidence.all.count).to eq(1)
  end

  specify '#batch_by_filter_scope :add, async' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :add,
      params: {
        confidence_level_id: confidence_level.id
      },
      project_id: Project.first.id,
      user_id: User.first.id,
      async_cutoff: 0)
    expect(Confidence.all.count).to eq(0)

    perform_enqueued_jobs

    expect(Confidence.all.count).to eq(1)
  end

  specify '#batch_by_filter_scope :add with venn filter' do
    # Create specimens and tag
    s1 = FactoryBot.create(:valid_specimen)
    s2 = FactoryBot.create(:valid_specimen)
    tag = FactoryBot.create(:valid_tag, tag_object: s1)

    # Create venn query URL that filters for tagged specimens
    venn_query_params = {
      'keyword_id_or' => [tag.keyword_id],
      'project_id' => Project.first.id
    }
    venn_url = "http://localhost:3000/collection_objects/filter.json?#{venn_query_params.to_query}"

    # Main query filters for both specimens, but venn restricts to tagged one
    q = ::Queries::CollectionObject::Filter.new(
      collection_object_id: [s1.id, s2.id],
      venn: venn_url,
      venn_mode: 'ab', # intersection (not 'a' which is except!)
      venn_ignore_pagination: true
    )

    # Verify venn params are preserved in the filter
    expect(q.params[:venn]).to be_present
    expect(q.params[:venn_mode]).to eq('ab')
    expect(q.params[:venn_ignore_pagination]).to be_truthy

    # Verify the reconstructed filter also preserves venn params
    reconstructed = ::Queries::Query::Filter.instantiated_base_filter({ 'collection_object_query' => q.params })
    expect(reconstructed.venn).to be_present
    expect(reconstructed.venn_mode).to eq(:ab)
    expect(reconstructed.venn_ignore_pagination).to be_truthy
    expect(reconstructed.all.to_a).to contain_exactly(s1)

    # Batch add confidence - should only add to s1 (which has the tag)
    Confidence.batch_by_filter_scope(
      filter_query: { 'collection_object_query' => q.params },
      mode: :add,
      params: {
        confidence_level_id: confidence_level.id
      }
    )

    # Only s1 should have the confidence
    expect(Confidence.where(confidence_object: s1).count).to eq(1)
    expect(Confidence.where(confidence_object: s2).count).to eq(0)
  end

  specify '#batch_by_filter_scope :add, async raises error when user_id is missing' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)

    expect {
      Confidence.batch_by_filter_scope(
        filter_query: { 'collection_object_query' => q.params },
        mode: :add,
        params: {
          confidence_level_id: confidence_level.id
        },
        project_id: Project.first.id,
        user_id: nil,
        async_cutoff: 0
      )
    }.to raise_error(TaxonWorks::Error, /user_id.*not set in batch_by_filter_scope/)
  end

  specify '#batch_by_filter_scope :add, async raises error when project_id is missing' do
    q = ::Queries::CollectionObject::Filter.new(collection_object_id: specimen.id)

    expect {
      Confidence.batch_by_filter_scope(
        filter_query: { 'collection_object_query' => q.params },
        mode: :add,
        params: {
          confidence_level_id: confidence_level.id
        },
        project_id: nil,
        user_id: User.first.id,
        async_cutoff: 0
      )
    }.to raise_error(TaxonWorks::Error, /project_id.*not set in batch_by_filter_scope/)
  end

  context 'validation' do
    before { confidence.save }

    specify 'confidence_level_id' do
      expect(confidence.errors.include?(:confidence_level)).to be_truthy
    end
  end

  context 'associations' do
    specify '#confidence_level' do
      expect(confidence.confidence_level = ConfidenceLevel.new()).to be_truthy
    end

    specify '#confidence_object' do
      expect(confidence.confidence_object = Specimen.new()).to be_truthy
    end
  end

  specify '#annotated_global_entity' do
    confidence.annotated_global_entity = specimen.to_global_id.to_s
    confidence.confidence_level_id = confidence_level.id
    expect(confidence.save!).to be_truthy
  end

end
