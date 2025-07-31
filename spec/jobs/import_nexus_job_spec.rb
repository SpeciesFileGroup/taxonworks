require 'rails_helper'

RSpec.describe ImportNexusJob, type: :job do
  specify 'queues job in import_nexus' do
    expect { ImportNexusJob.perform_later }.to have_enqueued_job.on_queue(:import_nexus)
  end

  describe 'Error handling' do
    let!(:user) { FactoryBot.create(:valid_user) }
    let!(:project) { FactoryBot.create(:valid_project,
      created_by_id: user.id, updated_by_id: user.id) }
    let!(:matrix) { FactoryBot.create(:valid_observation_matrix,
      created_by_id: user.id, updated_by_id: user.id, project_id: project.id) }

    before(:each) {
      Current.user_id = user.id
      Current.project_id = project.id
    }

    specify 'raises on document not found' do
      begin
        ImportNexusJob.perform_now(1234, matrix, {}, user.id, project.id)
      rescue
      end
      expect(ActionMailer::Base.deliveries.last.body).to include('nexus_document_id')
    end

    specify 'raises on nexus document parse error' do
      invalid_nexus_doc = Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/nexus/malformed.nex'),
          'text/plain'
        ))

      begin
        ImportNexusJob.perform_now(invalid_nexus_doc.id, matrix, {}, user.id,
          project.id)
      rescue
      end

      expect(ActionMailer::Base.deliveries.last.body).to include('nexus_document_id')
    end

    # TODO: do we really want an email every time a user accidentally submits
    # a binary file? (To be fair the controller catches this error, so it
    # should never get to the background job.)
    specify 'raises on non-text document' do
      pdf_doc = FactoryBot.create(:valid_document)

      begin
        ImportNexusJob.perform_now(pdf_doc.id, matrix, {}, user.id,
          project.id)
      rescue
      end

      expect(ActionMailer::Base.deliveries.last.body).to include('nexus_document_id')
    end

    specify 'raises on nexus_parser to TW error' do
      invalid_tw_nexus_doc = Document.create!(
        document_file: Rack::Test::UploadedFile.new(
          (Rails.root + 'spec/files/nexus/repeated_character_state_name.nex'),
          'text/plain'
        ))

      begin
        ImportNexusJob.perform_now(invalid_tw_nexus_doc.id, matrix, {},
          user.id, project.id)
      rescue
      end

      expect(ActionMailer::Base.deliveries.last.body).to include('nexus_document_id')
    end
  end
end
