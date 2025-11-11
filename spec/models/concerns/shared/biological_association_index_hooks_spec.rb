require 'rails_helper'

describe 'BiologicalAssociationIndexHooks', type: :model do

  context 'BiologicalRelationship updates' do
    let(:relationship) { FactoryBot.create(:valid_biological_relationship) }
    let!(:ba) { FactoryBot.create(:valid_biological_association, biological_relationship: relationship) }

    specify 'queues job when relationship name changes' do
      expect {
        relationship.update!(name: 'new_relationship_name')
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end

    specify 'marks affected indices with rebuild_set' do
      relationship.update!(name: 'another_name')

      # The index should have a rebuild_set value
      expect(ba.biological_association_index.reload.rebuild_set).to be_present
    end

    specify 'can skip index update with no_biological_association_index flag' do
      relationship.no_biological_association_index = true

      expect {
        relationship.update!(name: 'skipped_name')
      }.not_to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end
  end

  context 'Otu updates' do
    let(:otu) { FactoryBot.create(:valid_otu) }
    let!(:ba_as_subject) { FactoryBot.create(:valid_biological_association, biological_association_subject: otu) }
    let!(:ba_as_object) { FactoryBot.create(:valid_biological_association, biological_association_object: otu) }

    specify 'queues job when otu name changes' do
      expect {
        otu.update!(name: 'new_otu_name')
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end

    specify 'marks both subject and object indices' do
      otu.update!(name: 'updated_otu')

      expect(ba_as_subject.biological_association_index.reload.rebuild_set).to be_present
      expect(ba_as_object.biological_association_index.reload.rebuild_set).to be_present
    end

    specify 'biological_association_indices returns correct records' do
      indices = otu.send(:biological_association_indices)

      expect(indices).to contain_exactly(ba_as_subject.biological_association_index, ba_as_object.biological_association_index)
    end
  end

  context 'CollectionObject updates' do
    let(:specimen) { FactoryBot.create(:valid_specimen) }
    let!(:ba) { FactoryBot.create(:valid_biological_association, biological_association_subject: specimen) }

    specify 'queues job when specimen is touched' do
      expect {
        specimen.touch
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end

    specify 'marks affected index with rebuild_set' do
      specimen.touch

      expect(ba.biological_association_index.reload.rebuild_set).to be_present
    end
  end

  context 'Source updates' do
    let(:source) { FactoryBot.create(:valid_source_bibtex) }
    let(:ba) { FactoryBot.create(:valid_biological_association) }
    let!(:citation) { FactoryBot.create(:valid_citation, citation_object: ba, source: source) }

    specify 'queues job when source is updated' do
      expect {
        source.update!(year: 2024)
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end

    specify 'marks affected index with rebuild_set' do
      source.update!(year: 2024)

      expect(ba.biological_association_index.reload.rebuild_set).to be_present
    end
  end

  context 'Note updates' do
    let(:ba) { FactoryBot.create(:valid_biological_association) }
    let!(:note) { FactoryBot.create(:valid_note, note_object: ba, text: 'original note') }

    specify 'queues job when note text changes' do
      expect {
        note.update!(text: 'updated note text')
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end

    specify 'marks affected index with rebuild_set' do
      note.update!(text: 'updated note text')

      expect(ba.biological_association_index.reload.rebuild_set).to be_present
    end

    specify 'biological_association_indices returns correct record' do
      indices = note.biological_association_indices

      expect(indices).to include(ba.biological_association_index)
    end

    specify 'does not trigger for notes on other objects' do
      otu = FactoryBot.create(:valid_otu)
      otu_note = FactoryBot.create(:valid_note, note_object: otu)

      expect {
        otu_note.update!(text: 'should not trigger')
      }.not_to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end
  end

  context 'BiologicalProperty updates' do
    let(:property) { FactoryBot.create(:valid_biological_property) }
    let(:relationship) { FactoryBot.create(:valid_biological_relationship) }
    let!(:relationship_type) {
      BiologicalRelationshipType::BiologicalRelationshipSubjectType.create!(
        biological_relationship: relationship,
        biological_property: property
      )
    }
    let!(:ba) { FactoryBot.create(:valid_biological_association, biological_relationship: relationship) }

    specify 'queues job when property is updated' do
      expect {
        property.update!(name: 'updated_property')
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end
  end

  context 'job priority' do
    specify 'uses priority 1 for small batches (1-100)' do
      otu = FactoryBot.create(:valid_otu)
      FactoryBot.create(:valid_biological_association, biological_association_subject: otu)

      expect(BiologicalAssociationIndexRefreshJob).to receive(:set).with(priority: 1).and_call_original

      otu.update!(name: 'priority test')
    end
  end

  context 'batch processing' do
    specify 'processes updates in batches' do
      relationship = FactoryBot.create(:valid_biological_relationship)

      # Create multiple associations
      5.times do
        FactoryBot.create(:valid_biological_association, biological_relationship: relationship)
      end

      relationship.update!(name: 'batch_test')

      # All indices should have the same rebuild_set
      rebuild_sets = BiologicalAssociationIndex.where(biological_relationship: relationship)
                       .pluck(:rebuild_set).compact.uniq

      expect(rebuild_sets.length).to eq(1)
    end
  end

  context 'skip hook flag' do
    specify 'no_biological_association_index prevents hook from running' do
      otu = FactoryBot.create(:valid_otu)
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu)

      otu.no_biological_association_index = true

      expect {
        otu.update!(name: 'skipped')
      }.not_to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end
  end

  context 'with no associations' do
    specify 'does not queue job when no associations exist' do
      relationship = FactoryBot.create(:valid_biological_relationship)

      # No associations created

      expect {
        relationship.update!(name: 'no_assocs')
      }.not_to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end
  end
end
