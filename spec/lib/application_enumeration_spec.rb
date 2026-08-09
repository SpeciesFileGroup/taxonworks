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

    specify 'ignores cached relations by default' do
      geographic_item = FactoryBot.create(:valid_geographic_item)
      CachedMapItem.create!(
        otu: FactoryBot.create(:valid_otu),
        geographic_item:,
        type: 'CachedMapItem::WebLevel1',
        reference_count: 1
      )

      expect(ae.no_related_data?(geographic_item)).to be true
    end
  end

  context '.related_data_counts', type: :model do
    let(:otu) { FactoryBot.create(:valid_otu) }
    let(:otu_ignore) { [:identifiers, :uuids, :uris] } # Otus come with a UUID identifier.

    specify 'returns an empty hash when no related data' do
      note = FactoryBot.create(:valid_note)
      expect(ae.related_data_counts(Note, [note.id])).to eq({})
    end

    specify 'returns an empty hash when the only related data is ignored' do
      expect(ae.related_data_counts(Otu, [otu.id], ignore: otu_ignore)).to eq({})
    end

    specify 'counts has_many data (citations)' do
      otu.citations.create!(source: FactoryBot.create(:valid_source))
      counts = ae.related_data_counts(Otu, [otu.id], ignore: otu_ignore)
      # origin_citation/subsequent_citations are separate reflections scoped
      # onto the same underlying citations rows (by is_original) — a single
      # citation can legitimately show up under more than one relation name.
      expect(counts).to eq(citations: 1, origin_citation: 1, subsequent_citations: 1)
    end

    specify 'counts has_one data (attribution)' do
      lead = FactoryBot.create(:valid_lead)
      lead.create_attribution!(license: 'Attribution')
      counts = ae.related_data_counts(Lead, [lead.id])
      expect(counts[:attribution]).to eq(1)
    end

    specify 'excludes cached relations by default' do
      geographic_item = FactoryBot.create(:valid_geographic_item)
      CachedMapItem.create!(
        otu: FactoryBot.create(:valid_otu),
        geographic_item:,
        type: 'CachedMapItem::WebLevel1',
        reference_count: 1
      )
      expect(ae.related_data_counts(GeographicItem, [geographic_item.id])).to eq({})
    end

    specify 'sums matches across every id in the set, not just the first' do
      other_otu = FactoryBot.create(:valid_otu)
      otu.citations.create!(source: FactoryBot.create(:valid_source))
      other_otu.citations.create!(source: FactoryBot.create(:valid_source))
      counts = ae.related_data_counts(Otu, [otu.id, other_otu.id], ignore: otu_ignore)
      expect(counts[:citations]).to eq(2)
    end

    specify 'does not flag records outside the given id set' do
      other_otu = FactoryBot.create(:valid_otu)
      other_otu.citations.create!(source: FactoryBot.create(:valid_source))
      counts = ae.related_data_counts(Otu, [otu.id], ignore: otu_ignore)
      expect(counts).to eq({})
    end

    specify 'accepts an ActiveRecord::Relation in place of an Array of ids' do
      otu.citations.create!(source: FactoryBot.create(:valid_source))
      counts = ae.related_data_counts(Otu, Otu.where(id: otu.id), ignore: otu_ignore)
      expect(counts[:citations]).to eq(1)
    end

    context 'STI: base class reflections do not cover subclass-only associations' do
      # type_materials is declared on Protonym, not on the base TaxonName class.
      # A caller checking the wrong class silently misses it — this is exactly
      # the gap that motivated documenting the caveat rather than guessing at
      # STI descendants internally.
      specify 'TaxonName misses Protonym-only relations (type_materials)' do
        type_material = FactoryBot.create(:valid_type_material)
        expect(ae.related_data_counts(TaxonName, [type_material.protonym_id])).not_to have_key(:type_materials)
      end

      specify 'Protonym catches its own type_materials' do
        type_material = FactoryBot.create(:valid_type_material)
        counts = ae.related_data_counts(Protonym, [type_material.protonym_id])
        expect(counts[:type_materials]).to eq(1)
      end
    end
  end

end
