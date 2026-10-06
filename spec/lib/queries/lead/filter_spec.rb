require 'rails_helper'

describe Queries::Lead::Filter, type: :model do

  let(:q) { Queries::Lead::Filter.new({}) }

  let(:otu1) { FactoryBot.create(:valid_otu, name: 'one') }
  let(:otu2) { FactoryBot.create(:valid_otu, name: 'two') }
  let(:otu3) { FactoryBot.create(:valid_otu, name: 'three') }

  # Dichotomous key, otu1 at a leaf
  let!(:dichotomous_key) {
    FactoryBot.create(:valid_lead, text: 'Key to beetles', description: 'Adults only', is_public: true)
  }
  let!(:dichotomous_left) { dichotomous_key.children.create!(text: 'Elytra short', otu: otu1) }
  let!(:dichotomous_right) { dichotomous_key.children.create!(text: 'Elytra long') }

  # Simple (virtual) key, otu2 attached to a child
  let!(:simple_key) {
    Lead.create!(text: 'Key to flies', is_virtual: true)
  }
  let!(:simple_child) {
    Lead.create!(parent: simple_key, text: nil, is_virtual: true, otu: otu2)
  }

  specify 'returns only keys (root leads)' do
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id, simple_key.id)
  end

  specify '#lead_id' do
    q.lead_id = [simple_key.id]
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  specify '#text, partial' do
    q.text = 'beetles'
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

  specify '#text, exact' do
    q.text = 'Key to'
    q.text_exact = true
    expect(q.all.pluck(:id)).to be_empty
  end

  specify '#text does not match couplet text' do
    q.text = 'Elytra'
    expect(q.all.pluck(:id)).to be_empty
  end

  specify '#description' do
    q.description = 'adults'
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

  specify '#is_virtual true' do
    q.is_virtual = true
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  specify '#is_virtual false' do
    q.is_virtual = false
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

  specify '#is_public true' do
    q.is_public = true
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

  specify '#is_public false' do
    q.is_public = false
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  specify '#otu_id matches OTUs on any lead in the key' do
    q.otu_id = [otu1.id]
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

  specify '#otu_id matches OTUs on simple key children' do
    q.otu_id = [otu2.id]
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  specify '#otu_id matches OTUs on the root lead' do
    k = FactoryBot.create(:valid_lead, text: 'Key to otu3', otu: otu3)
    q.otu_id = [otu3.id]
    expect(q.all.pluck(:id)).to contain_exactly(k.id)
  end

  specify '#otu_id matches lead item OTUs' do
    FactoryBot.create(:valid_lead_item, lead: dichotomous_right, otu: otu3)
    q.otu_id = [otu3.id]
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

  specify '#otu_id, multiple' do
    q.otu_id = [otu1.id, otu2.id]
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id, simple_key.id)
  end

  specify '#otus true' do
    FactoryBot.create(:valid_lead, text: 'No otus')
    q.otus = true
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id, simple_key.id)
  end

  specify '#otus false' do
    k = FactoryBot.create(:valid_lead, text: 'No otus')
    q.otus = false
    expect(q.all.pluck(:id)).to contain_exactly(k.id)
  end

  context 'observation matrices' do
    let(:observation_matrix) { FactoryBot.create(:valid_observation_matrix) }

    before { dichotomous_key.update!(observation_matrix:) }

    specify '#observation_matrix_id' do
      q.observation_matrix_id = [observation_matrix.id]
      expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
    end

    specify '#observation_matrix true' do
      q.observation_matrix = true
      expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
    end

    specify '#observation_matrix false' do
      q.observation_matrix = false
      expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
    end
  end

  specify '#otu_query' do
    q = Queries::Lead::Filter.new(otu_query: { otu_id: [otu2.id] })
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  specify '#taxon_name_query' do
    o = FactoryBot.create(:valid_otu, taxon_name: FactoryBot.create(:relationship_species))
    k = FactoryBot.create(:valid_lead, text: 'Key with a name')
    k.children.create!(text: 'named', otu: o)

    q = Queries::Lead::Filter.new(taxon_name_query: { taxon_name_id: [o.taxon_name_id] })
    expect(q.all.pluck(:id)).to contain_exactly(k.id)
  end

  specify '#source_query' do
    c = FactoryBot.create(:valid_citation, citation_object: simple_key)
    q = Queries::Lead::Filter.new(source_query: { source_id: [c.source_id] })
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  specify '#citations' do
    FactoryBot.create(:valid_citation, citation_object: simple_key)
    q.citations = true
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  specify '#tags' do
    FactoryBot.create(:valid_tag, tag_object: dichotomous_key)
    q.tags = true
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

  context 'keywords (e.g. life stage, sex) on keys' do
    let(:adult) { FactoryBot.create(:valid_keyword, name: 'adult') }
    let(:male) { FactoryBot.create(:valid_keyword, name: 'male') }

    before do
      FactoryBot.create(:valid_tag, tag_object: dichotomous_key, keyword: adult)
      FactoryBot.create(:valid_tag, tag_object: dichotomous_key, keyword: male)
      FactoryBot.create(:valid_tag, tag_object: simple_key, keyword: adult)
    end

    specify '#keyword_id_or' do
      q.keyword_id_or = [male.id]
      expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
    end

    specify '#keyword_id_and' do
      q.keyword_id_and = [adult.id, male.id]
      expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
    end

    specify '#keyword_id_or, multiple' do
      q.keyword_id_or = [adult.id, male.id]
      expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id, simple_key.id)
    end

    specify '#keyword_id_or with #exclude_tags' do
      q.keyword_id_or = [male.id]
      q.exclude_tags = true
      expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
    end
  end

  specify '#data_attribute_predicate_id' do
    predicate = FactoryBot.create(:valid_predicate, name: 'life stage')
    FactoryBot.create(:valid_data_attribute_internal_attribute, attribute_subject: simple_key, predicate:, value: '2nd instar')
    q.data_attribute_predicate_id = [predicate.id]
    expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
  end

  context 'annotation filter subqueries' do
    let(:keyword) { FactoryBot.create(:valid_keyword, name: 'female') }

    specify '#tag_query' do
      Tag.create!(tag_object: simple_key, keyword:)
      Tag.create!(tag_object: otu1, keyword:) # not a key
      q = Queries::Lead::Filter.new(tag_query: { keyword_id: [keyword.id] })
      expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
    end

    specify '#citation_query' do
      c = FactoryBot.create(:valid_citation, citation_object: dichotomous_key)
      q = Queries::Lead::Filter.new(citation_query: { citation_id: [c.id] })
      expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
    end

    specify '#data_attribute_query' do
      predicate = FactoryBot.create(:valid_predicate, name: 'sex')
      da = ::InternalAttribute.create!(attribute_subject: simple_key, value: 'female', predicate:)
      q = Queries::Lead::Filter.new(data_attribute_query: { data_attribute_id: [da.id] })
      expect(q.all.pluck(:id)).to contain_exactly(simple_key.id)
    end
  end

  specify '#api excludes non-public keys' do
    q = Queries::Lead::Filter.new(api: true)
    expect(q.all.pluck(:id)).to contain_exactly(dichotomous_key.id)
  end

end
