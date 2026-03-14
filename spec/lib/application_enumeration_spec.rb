require 'rails_helper'
require 'application_enumeration'

describe 'ApplicationEnumeration' do

  let(:ae) { ApplicationEnumeration }

  specify '.data_models #2' do
    expect(ae.data_models).to include(Identifier)
  end

  specify '.data_models #1' do
    expect(ae.data_models).to include(AlternateValue)
  end

  specify '.data_models #3' do
    expect(ae.data_models).to include(TypeMaterial)
  end

  specify '.citable_relations :all keys' do
    h = ae.citable_relations(Otu)
    expect(h.keys).to contain_exactly(:has_many, :has_one, :belongs_to)
  end

  specify '.citable_relations has_many' do
    h = ae.citable_relations(Otu, :has_many)
    expect(h[:has_many]).to include(:images, :confidences, :collection_objects)
    expect(h[:has_many]).not_to include(:pinboard_items)
  end

  specify '.citable_relations has_one' do
    h = ae.citable_relations(Lead, :has_one)
    expect(h[:has_one]).to include(:taxon_name) # through otu
    # TODO find a klass with a good uncitable has_one
  end

  specify '.citable_relations belongs_to' do
    h = ae.citable_relations(CollectionObject, :belongs_to)
    expect(h[:belongs_to]).to include(:collecting_event)
    expect(h[:belongs_to]).not_to include(:user)
  end

  context '.filter_sti_relations' do
    specify 'drops STI subclass relation when parent association is unscoped' do
      result = ae.filter_sti_relations(Otu, [:taxon_name, :protonym])
      expect(result.keys).to include(:taxon_name)
      expect(result.keys).not_to include(:protonym)
    end

    specify 'result is order-independent' do
      a = ae.filter_sti_relations(Otu, [:taxon_name, :protonym]).keys
      b = ae.filter_sti_relations(Otu, [:protonym, :taxon_name]).keys
      expect(a).to match_array(b)
    end

    specify 'keeps scoped STI subclass when parent is also scoped' do
      # If the parent association is scoped it cannot be guaranteed to cover all
      # records the subclass returns, so neither should be dropped.
      # NOTE: no real-world example of this pattern currently exists in TaxonWorks;
      # tested here as documentation of the known limitation.
      result = ae.filter_sti_relations(Otu, [:protonym])
      expect(result.keys).to include(:protonym)
    end

    specify 'keeps scoped sibling STI associations when no unscoped parent is present' do
      # subject_ and object_biological_relationship_types are both scoped and
      # neither is a subclass of the other, so both should be retained.
      result = ae.filter_sti_relations(
        BiologicalRelationship,
        [:subject_biological_relationship_types, :object_biological_relationship_types]
      )
      expect(result.keys).to include(:subject_biological_relationship_types, :object_biological_relationship_types)
    end

    specify 'drops scoped STI subclass associations when unscoped parent is present' do
      # biological_relationship_types is unscoped and covers all records that the
      # scoped subclass associations return, so the subclasses should be dropped.
      result = ae.filter_sti_relations(
        BiologicalRelationship,
        [:biological_relationship_types, :subject_biological_relationship_types, :object_biological_relationship_types]
      )
      expect(result.keys).to include(:biological_relationship_types)
      expect(result.keys).not_to include(:subject_biological_relationship_types, :object_biological_relationship_types)
    end

    specify 'does not raise on polymorphic associations' do
      expect { ae.filter_sti_relations(AssertedDistribution, [:asserted_distribution_object]) }.not_to raise_error
    end

    specify 'retains polymorphic associations in result' do
      result = ae.filter_sti_relations(AssertedDistribution, [:asserted_distribution_object])
      expect(result.keys).to include(:asserted_distribution_object)
    end
  end

  context '.no_related_data?', type: :model do
    let(:otu) { FactoryBot.create(:valid_otu) }

    specify 'returns true when no data' do
      note = FactoryBot.create(:valid_note)
      expect(ae.no_related_data?(note)).to be true
    end

    specify 'returns true when related data is ignored' do
      # Otus come with a UUID identifier.
      expect(ae.no_related_data?(otu, ignore: [:identifiers, :uuids])).to be true
    end

    specify 'returns false when object has related has_many data (citations)' do
      otu.citations.create!(source: FactoryBot.create(:valid_source))
      expect(ae.no_related_data?(otu)).to be false
    end

    specify 'returns false when object has related has_one data (attribution)' do
      lead = FactoryBot.create(:valid_lead)
      lead.create_attribution!(license: 'Attribution')
      expect(ae.no_related_data?(lead)).to be false
    end
  end

end
