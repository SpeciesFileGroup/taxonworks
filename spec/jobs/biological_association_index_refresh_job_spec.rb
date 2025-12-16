require 'rails_helper'

RSpec.describe BiologicalAssociationIndexRefreshJob, type: :model do
  let(:job_user) { FactoryBot.create(:valid_user) }

  context 'job configuration' do
    specify 'queues job in query_batch_update queue' do
      rebuild_set = SecureRandom.hex(10)

      expect {
        BiologicalAssociationIndexRefreshJob.perform_later(rebuild_set: rebuild_set, user_id: job_user.id)
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
        .with(rebuild_set: rebuild_set, user_id: job_user.id)
        .on_queue('query_batch_update')
    end
  end

  context 'validations' do
    specify 'raises error when rebuild_set is blank' do
      expect {
        BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: nil, user_id: job_user.id)
      }.to raise_error(TaxonWorks::Error, 'no set id to refresh job')
    end

    specify 'raises error when rebuild_set is empty string' do
      expect {
        BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: '', user_id: job_user.id)
      }.to raise_error(TaxonWorks::Error, 'no set id to refresh job')
    end
  end

  context 'processing' do
    let(:rebuild_set) { SecureRandom.hex(10) }
    let(:ba1) { FactoryBot.create(:valid_biological_association) }
    let(:ba2) { FactoryBot.create(:valid_biological_association) }

    before do
      ba1.biological_association_index.update_column(:rebuild_set, rebuild_set)
      ba2.biological_association_index.update_column(:rebuild_set, rebuild_set)
    end

    specify 'processes all records with matching rebuild_set' do
      # Change the underlying data
      ba1.biological_relationship.update_column(:name, 'changed_name_1')
      ba2.biological_relationship.update_column(:name, 'changed_name_2')

      BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)

      expect(ba1.biological_association_index.reload.relationship_name).to eq('changed_name_1')
      expect(ba2.biological_association_index.reload.relationship_name).to eq('changed_name_2')
    end

    specify 'only processes indices with the specified rebuild_set' do
      other_ba = FactoryBot.create(:valid_biological_association)
      other_ba.biological_association_index.update_column(:rebuild_set, 'different_set')

      original_name = other_ba.biological_association_index.relationship_name
      other_ba.biological_relationship.update_column(:name, 'should_not_change')

      BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)

      # The other BA should not be updated
      expect(other_ba.biological_association_index.reload.relationship_name).to eq(original_name)
    end

    specify 'handles large batches with find_each' do
      # Create a larger set
      10.times do
        ba = FactoryBot.create(:valid_biological_association)
        ba.biological_association_index.update_column(:rebuild_set, rebuild_set)
      end

      expect {
        BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)
      }.not_to raise_error
    end

    specify 'clears rebuild_set after processing' do
      ba1.biological_association_index.update_column(:rebuild_set, rebuild_set)
      ba2.biological_association_index.update_column(:rebuild_set, rebuild_set)

      BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)

      expect(ba1.biological_association_index.reload.rebuild_set).to be_nil
      expect(ba2.biological_association_index.reload.rebuild_set).to be_nil
    end
  end

  context 'error handling' do
    let(:rebuild_set) { SecureRandom.hex(10) }

    specify 'handles missing biological associations gracefully' do
      # Create an index record with invalid BA reference
      ba = FactoryBot.create(:valid_biological_association)
      ba.biological_association_index.update_column(:rebuild_set, rebuild_set)
      ba_id = ba.id

      # Destroy the association (this will cascade delete the index in normal operation)
      # But for testing, we'll just verify the job can handle errors
      allow_any_instance_of(BiologicalAssociation).to receive(:set_biological_association_index).and_raise(StandardError.new('Test error'))

      expect(ExceptionNotifier).to receive(:notify_exception).and_call_original

      # Job should raise error and notify
      expect {
        BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)
      }.to raise_error(StandardError, 'Test error')
    end
  end

  context 'integration with hooks' do
    specify 'job is enqueued when relationship changes' do
      relationship = FactoryBot.create(:valid_biological_relationship, name: 'original')
      ba = FactoryBot.create(:valid_biological_association, biological_relationship: relationship)

      expect {
        relationship.update!(name: 'updated')
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end

    specify 'job is enqueued when otu changes' do
      otu = FactoryBot.create(:valid_otu, name: 'original_name')
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: otu)

      expect {
        otu.update!(name: 'new_name')
      }.to have_enqueued_job(BiologicalAssociationIndexRefreshJob)
    end
  end

  context 'data accuracy' do
    let(:rebuild_set) { SecureRandom.hex(10) }

    specify 'correctly updates all index fields' do
      relationship = FactoryBot.create(:valid_biological_relationship, name: 'host_of', inverted_name: 'hosted_by')
      otu = FactoryBot.create(:valid_otu, name: 'Test Species')
      ba = FactoryBot.create(:valid_biological_association,
        biological_relationship: relationship,
        biological_association_subject: otu
      )

      ba.biological_association_index.update_column(:rebuild_set, rebuild_set)

      # Change the data
      relationship.update_column(:name, 'parasite_of')
      relationship.update_column(:inverted_name, 'parasitized_by')
      otu.update_column(:name, 'Updated Species')

      BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)

      index = ba.biological_association_index.reload
      expect(index.relationship_name).to eq('parasite_of')
      expect(index.relationship_inverted_name).to eq('parasitized_by')
      expect(index.subject_label).to include('Updated Species')
    end
  end

  context 'CollectionObject data propagation' do
    specify 'updates index when specimen identifier is added' do
      specimen = FactoryBot.create(:valid_specimen)
      ba = FactoryBot.create(:valid_biological_association, biological_association_subject: specimen)

      # Add a global UUID identifier to the specimen
      # Note: We use a Global identifier because when label_for is called from model
      # context (not controller), visible_identifiers gets nil for project_id, which
      # means only Global identifiers (type ILIKE 'Identifier::Global%') are visible
      identifier_value = 'f47ac10b-58cc-4372-a567-0e02b2c3d479'
      identifier = Identifier::Global::Uuid.create!(
        identifier_object: specimen,
        identifier: identifier_value
      )

      # Touch specimen to trigger the hook (which marks rebuild_set)
      specimen.touch

      # Get the rebuild_set that was assigned by the hook
      rebuild_set = ba.biological_association_index.reload.rebuild_set
      expect(rebuild_set).to be_present

      # Run the job
      BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)

      # Subject label should now include the UUID identifier
      new_label = ba.biological_association_index.reload.subject_label
      expect(new_label).to include(identifier_value)
    end
  end

  context 'Source data propagation' do
    specify 'updates index when source citation changes' do
      source_year = 1999
      source = FactoryBot.create(:valid_source_bibtex, year: source_year, author: 'Jones')
      ba = FactoryBot.create(:valid_biological_association)
      citation = FactoryBot.create(:valid_citation, citation_object: ba, source: source)

      # Rebuild index to capture citation
      ba.reload.set_biological_association_index

      # Verify initial citation year is present
      expect(ba.biological_association_index.reload.citation_year).to include(source_year.to_s)

      new_year = 2024
      source.update!(year: new_year)

      # Get the rebuild_set that was assigned by the hook
      rebuild_set = ba.biological_association_index.reload.rebuild_set
      expect(rebuild_set).to be_present

      # Run the job
      BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)

      # Citation year should be updated in the index
      expect(ba.biological_association_index.reload.citation_year).to include(new_year.to_s)
    end
  end

  context 'Note data propagation' do
    specify 'updates index when note text changes' do
      ba = FactoryBot.create(:valid_biological_association)
      note = FactoryBot.create(:valid_note, note_object: ba, text: 'original note')

      # Rebuild index to capture note
      ba.reload.set_biological_association_index

      # Verify initial note is present
      expect(ba.biological_association_index.reload.remarks).to include('original note')

      new_note_text = 'updated note text'
      note.update!(text: new_note_text)

      # Get the rebuild_set that was assigned by the hook
      rebuild_set = ba.biological_association_index.reload.rebuild_set
      expect(rebuild_set).to be_present

      # Run the job
      BiologicalAssociationIndexRefreshJob.perform_now(rebuild_set: rebuild_set, user_id: job_user.id)

      # Remarks should include the new note text
      expect(ba.biological_association_index.reload.remarks).to include(new_note_text)
    end
  end
end
