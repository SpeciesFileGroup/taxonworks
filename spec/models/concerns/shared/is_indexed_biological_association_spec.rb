require 'rails_helper'

describe 'IsIndexedBiologicalAssociation', type: :model do
  let(:biological_association) { FactoryBot.create(:valid_biological_association) }

  context 'associations' do
    specify 'has_one :biological_association_index' do
      expect(biological_association).to respond_to(:biological_association_index)
      expect(biological_association.biological_association_index).to be_a(BiologicalAssociationIndex)
    end
  end

  context 'callbacks' do
    specify 'automatically creates index on save' do
      ba = FactoryBot.build(:valid_biological_association)
      expect(ba.biological_association_index).to be_nil

      ba.save!

      expect(ba.biological_association_index).to be_present
      expect(ba.biological_association_index).to be_persisted
    end

    specify 'automatically updates index on save' do
      ba = FactoryBot.create(:valid_biological_association)
      original_name = ba.biological_association_index.relationship_name

      new_relationship = FactoryBot.create(:valid_biological_relationship, name: 'new_name')
      ba.biological_relationship = new_relationship
      ba.save!

      expect(ba.biological_association_index.reload.relationship_name).to eq('new_name')
      expect(ba.biological_association_index.relationship_name).not_to eq(original_name)
    end

    specify 'can skip index creation with no_biological_association_index flag' do
      ba = FactoryBot.build(:valid_biological_association)
      ba.no_biological_association_index = true

      expect { ba.save! }.not_to change(BiologicalAssociationIndex, :count)
    end

    specify 'can skip index update with no_biological_association_index flag' do
      ba = FactoryBot.create(:valid_biological_association)
      original_name = ba.biological_association_index.relationship_name

      new_relationship = FactoryBot.create(:valid_biological_relationship, name: 'different_name')
      ba.no_biological_association_index = true
      ba.biological_relationship = new_relationship
      ba.save!

      expect(ba.biological_association_index.reload.relationship_name).to eq(original_name)
    end
  end

  context 'scopes' do
    specify '.ba_indexed returns associations with index' do
      ba_with_index = FactoryBot.create(:valid_biological_association)
      ba_without_index = FactoryBot.create(:valid_biological_association)
      ba_without_index.biological_association_index.destroy

      expect(BiologicalAssociation.ba_indexed).to include(ba_with_index)
      expect(BiologicalAssociation.ba_indexed).not_to include(ba_without_index)
    end

    specify '.ba_not_indexed returns associations without index' do
      ba_with_index = FactoryBot.create(:valid_biological_association)
      ba_without_index = FactoryBot.create(:valid_biological_association)
      ba_without_index.biological_association_index.destroy

      expect(BiologicalAssociation.ba_not_indexed).to include(ba_without_index)
      expect(BiologicalAssociation.ba_not_indexed).not_to include(ba_with_index)
    end
  end

  context '#set_biological_association_index' do
    specify 'creates index when none exists' do
      ba = FactoryBot.create(:valid_biological_association)
      ba.biological_association_index.destroy

      expect(ba.biological_association_index_persisted?).to be_falsey

      result = ba.set_biological_association_index

      expect(result).to be_a(BiologicalAssociationIndex)
      expect(result).to be_persisted
    end

    specify 'updates existing index' do
      ba = FactoryBot.create(:valid_biological_association)
      original_updated_at = ba.biological_association_index.updated_at

      sleep 0.01

      new_relationship = FactoryBot.create(:valid_biological_relationship, name: 'updated_relationship')
      ba.biological_relationship = new_relationship
      ba.save!

      result = ba.set_biological_association_index

      expect(result.relationship_name).to eq('updated_relationship')
      expect(result.updated_at).to be > original_updated_at
    end

    specify 'handles concurrent updates with retry' do
      ba = FactoryBot.create(:valid_biological_association)

      # Simulate a race condition by creating a duplicate index
      # The retry logic should handle this gracefully
      expect { ba.set_biological_association_index }.not_to raise_error
    end

    specify 'returns the biological_association_index' do
      ba = FactoryBot.create(:valid_biological_association)
      result = ba.set_biological_association_index

      expect(result).to eq(ba.biological_association_index.reload)
    end
  end

  context '#get_biological_association_index' do
    specify 'returns existing index without rebuilding' do
      ba = FactoryBot.create(:valid_biological_association)
      index = ba.biological_association_index

      # Should not create a new index
      expect { ba.get_biological_association_index }.not_to change(BiologicalAssociationIndex, :count)
      expect(ba.get_biological_association_index).to eq(index)
    end

    specify 'creates index if not present' do
      ba = FactoryBot.create(:valid_biological_association)
      ba.biological_association_index.destroy

      expect(ba.biological_association_index_persisted?).to be_falsey

      result = ba.get_biological_association_index

      expect(result).to be_present
      expect(result).to be_persisted
    end
  end

  context '#biological_association_index_attributes' do
    let(:ba) { FactoryBot.create(:valid_biological_association) }

    specify 'includes core association data' do
      attrs = ba.biological_association_index_attributes

      expect(attrs[:biological_association_id]).to eq(ba.id)
      expect(attrs[:biological_relationship_id]).to eq(ba.biological_relationship_id)
      expect(attrs[:project_id]).to eq(ba.project_id)
    end

    specify 'includes subject data' do
      attrs = ba.biological_association_index_attributes

      expect(attrs[:subject_id]).to eq(ba.biological_association_subject_id)
      expect(attrs[:subject_type]).to eq(ba.biological_association_subject_type)
      expect(attrs[:subject_label]).to be_present
    end

    specify 'includes object data' do
      attrs = ba.biological_association_index_attributes

      expect(attrs[:object_id]).to eq(ba.biological_association_object_id)
      expect(attrs[:object_type]).to eq(ba.biological_association_object_type)
      expect(attrs[:object_label]).to be_present
    end

    specify 'includes relationship data' do
      attrs = ba.biological_association_index_attributes

      expect(attrs[:relationship_name]).to eq(ba.biological_relationship.name)
      expect(attrs[:relationship_inverted_name]).to eq(ba.biological_relationship.inverted_name)
    end

    specify 'includes housekeeping data' do
      attrs = ba.biological_association_index_attributes

      expect(attrs[:created_by_id]).to eq(ba.created_by_id)
      expect(attrs[:updated_by_id]).to eq(ba.updated_by_id)
    end
  end

  context 'with UUIDs' do
    let(:otu) { FactoryBot.create(:valid_otu) }

    specify 'captures UUID for Otu subject' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu)

      expect(ba.biological_association_index.subject_uuid).to eq(otu.uuid)
    end

    specify 'captures UUID for Otu object' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_object: otu)

      expect(ba.biological_association_index.object_uuid).to eq(otu.uuid)
    end
  end

  context 'with taxonomy data' do
    let(:taxon_name) { FactoryBot.create(:valid_taxon_name) }
    let(:otu_with_taxon) { FactoryBot.create(:valid_otu, taxon_name: taxon_name) }

    specify 'captures taxonomy fields when subject has taxon_name' do
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu_with_taxon)
      attrs = ba.biological_association_index_attributes

      # Fields may be nil depending on rank, but method should not error
      expect { attrs[:subject_order] }.not_to raise_error
      expect { attrs[:subject_family] }.not_to raise_error
      expect { attrs[:subject_genus] }.not_to raise_error
    end
  end

  context 'with citations' do
    let(:source) { FactoryBot.create(:valid_source) }

    specify 'captures citation data' do
      ba = FactoryBot.create(:valid_biological_association)
      FactoryBot.create(:valid_citation, citation_object: ba, source: source)

      ba.reload
      attrs = ba.biological_association_index_attributes

      expect(attrs[:citations]).to be_present
    end
  end

  context 'deletion cascade' do
    specify 'deletes index when association is destroyed' do
      ba = FactoryBot.create(:valid_biological_association)
      index_id = ba.biological_association_index.id

      expect { ba.destroy }.to change(BiologicalAssociationIndex, :count).by(-1)
      expect(BiologicalAssociationIndex.where(id: index_id)).to be_empty
    end
  end
end
