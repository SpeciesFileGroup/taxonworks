require 'rails_helper'

describe BiologicalAssociationIndex, type: :model do
  let(:biological_association) { FactoryBot.create(:valid_biological_association) }
  let(:index) { biological_association.biological_association_index }

  context 'associations' do
    specify 'belongs_to biological_association' do
      expect(index.biological_association).to eq(biological_association)
    end

    specify 'belongs_to biological_relationship' do
      expect(index.biological_relationship).to eq(biological_association.biological_relationship)
    end
  end

  context 'validations' do
    specify 'requires biological_association' do
      index = BiologicalAssociationIndex.new
      index.valid?
      expect(index.errors.include?(:biological_association)).to be_truthy
    end

    specify 'requires biological_relationship' do
      index = BiologicalAssociationIndex.new
      index.valid?
      expect(index.errors.include?(:biological_relationship)).to be_truthy
    end
  end

  context 'automatic creation' do
    specify 'creates index when biological association is created' do
      ba = FactoryBot.build(:valid_biological_association)
      expect { ba.save! }.to change(BiologicalAssociationIndex, :count).by(1)
    end

    specify 'index has correct subject_id' do
      expect(index.subject_id).to eq(biological_association.biological_association_subject_id)
    end

    specify 'index has correct subject_type' do
      expect(index.subject_type).to eq(biological_association.biological_association_subject_type)
    end

    specify 'index has subject_label' do
      expect(index.subject_label).to be_present
    end

    specify 'index has correct object_id' do
      expect(index.object_id).to eq(biological_association.biological_association_object_id)
    end

    specify 'index has correct object_type' do
      expect(index.object_type).to eq(biological_association.biological_association_object_type)
    end

    specify 'index has object_label' do
      expect(index.object_label).to be_present
    end

    specify 'index has correct relationship_name' do
      expect(index.relationship_name).to eq(biological_association.biological_relationship.name)
    end

    specify 'index has correct relationship_inverted_name' do
      expect(index.relationship_inverted_name).to eq(biological_association.biological_relationship.inverted_name)
    end
  end

  context 'automatic updates' do
    specify 'updates index when biological association changes' do
      ba = FactoryBot.create(:valid_biological_association)
      new_relationship = FactoryBot.create(:valid_biological_relationship, name: 'new_relationship')

      ba.biological_relationship = new_relationship
      ba.save!

      expect(ba.biological_association_index.reload.relationship_name).to eq('new_relationship')
    end

    specify 'updates timestamps when index is updated' do
      ba = FactoryBot.create(:valid_biological_association)
      original_updated_at = ba.biological_association_index.updated_at

      sleep 0.01 # Ensure time difference

      new_relationship = FactoryBot.create(:valid_biological_relationship)
      ba.biological_relationship = new_relationship
      ba.save!

      expect(ba.biological_association_index.reload.updated_at).to be > original_updated_at
    end
  end

  context 'deletion' do
    specify 'deletes index when biological association is deleted' do
      ba = FactoryBot.create(:valid_biological_association)
      index_id = ba.biological_association_index.id

      ba.destroy!

      expect(BiologicalAssociationIndex.where(id: index_id).count).to eq(0)
    end
  end

  context 'with taxonomy data' do
    let(:genus) { FactoryBot.create(:iczn_genus) }
    let(:family) { genus.ancestor_at_rank('family') }
    let(:order) { genus.ancestor_at_rank('order') }
    let(:otu_with_genus) { FactoryBot.create(:valid_otu, taxon_name: genus) }

    specify 'captures subject_genus when subject has genus rank taxon' do
      ba = FactoryBot.create(:valid_biological_association,
        biological_association_subject: otu_with_genus
      )

      expect(ba.biological_association_index.subject_genus).to eq('Erythroneura')
    end

    specify 'captures subject_family when subject has family in ancestry' do
      ba = FactoryBot.create(:valid_biological_association,
        biological_association_subject: otu_with_genus
      )

      expect(ba.biological_association_index.subject_family).to eq('Cicadellidae')
    end

    specify 'captures object_genus when object has genus rank taxon' do
      ba = FactoryBot.create(:valid_biological_association,
        biological_association_object: otu_with_genus
      )

      expect(ba.biological_association_index.object_genus).to eq('Erythroneura')
    end

    specify 'captures object_family when object has family in ancestry' do
      ba = FactoryBot.create(:valid_biological_association,
        biological_association_object: otu_with_genus
      )

      expect(ba.biological_association_index.object_family).to eq('Cicadellidae')
    end
  end

  context 'with citations' do
    let(:source_author) { 'Smith' }
    let(:source_year) { 1950 }
    let(:source) { FactoryBot.create(:valid_source_bibtex, year: source_year, author: source_author) }

    specify 'captures citations when source is added' do
      ba = FactoryBot.create(:valid_biological_association)
      FactoryBot.create(:valid_citation, citation_object: ba, source: source)

      # Reload to pick up new citations and trigger index rebuild
      ba.reload
      ba.set_biological_association_index

      expect(ba.biological_association_index.reload.citations).to include(source_author)
    end

    specify 'captures citation_year from source' do
      ba = FactoryBot.create(:valid_biological_association)
      FactoryBot.create(:valid_citation, citation_object: ba, source: source)

      # Reload to pick up new citations and trigger index rebuild
      ba.reload
      ba.set_biological_association_index

      expect(ba.biological_association_index.reload.citation_year).to include(source_year.to_s)
    end
  end

  context 'with notes' do
    specify 'captures notes in remarks field' do
      ba = FactoryBot.create(:valid_biological_association)
      FactoryBot.create(:valid_note, note_object: ba, text: 'Test note')

      # Trigger index rebuild
      ba.set_biological_association_index

      expect(ba.biological_association_index.reload.remarks).to include('Test note')
    end
  end

  context 'rebuild_set tracking' do
    specify 'can set rebuild_set for batch processing' do
      rebuild_set = SecureRandom.hex(10)
      index.update_column(:rebuild_set, rebuild_set)

      expect(BiologicalAssociationIndex.where(rebuild_set: rebuild_set).count).to eq(1)
    end

    specify 'can query by rebuild_set' do
      rebuild_set = SecureRandom.hex(10)
      ba1 = FactoryBot.create(:valid_biological_association)
      ba2 = FactoryBot.create(:valid_biological_association)

      ba1.biological_association_index.update_column(:rebuild_set, rebuild_set)
      ba2.biological_association_index.update_column(:rebuild_set, rebuild_set)

      expect(BiologicalAssociationIndex.where(rebuild_set: rebuild_set).count).to eq(2)
    end
  end

  context 'established_date handling for all BA subject types' do
    let(:otu) { FactoryBot.create(:valid_otu) }
    let(:relationship) { FactoryBot.create(:valid_biological_relationship) }

    # This catches when a new type is added but biological_association_established_date isn't updated
    specify 'handles all valid subject types with Otu as object' do
      subject_types = [
        FactoryBot.create(:valid_otu),
        FactoryBot.create(:valid_specimen),
        FactoryBot.create(:valid_field_occurrence)
      ]

      subject_types.each do |subject|
        ba = FactoryBot.create(:valid_biological_association,
          biological_association_subject: subject,
          biological_association_object: otu
        )

        # Should create index without error
        expect(ba.biological_association_index).to be_present
        # Should not set established_date to error string
        expect(ba.biological_association_index.established_date).not_to eq('BAD DATA: TYPE ERROR')
      end
    end
  end
end
