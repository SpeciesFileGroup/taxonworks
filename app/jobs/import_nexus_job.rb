class ImportNexusJob < ApplicationJob
  queue_as :import_nexus
  include Lib::Vendor::NexusHelper

  def perform(nexus_doc_id, matrix, options, uid, project_id)
    Current.user_id = uid
    Current.project_id = project_id

    nf = document_to_nexus(nexus_doc_id, matrix)

    create_matrix_from_nexus(
      nexus_doc_id,
      nf,
      matrix,
      options
    )
  end

  def document_to_nexus(doc_id, matrix)
    begin
      Vendor::NexusParser.document_id_to_nexus(doc_id)
    rescue => e
      ExceptionNotifier.notify_exception(e,
        data: { nexus_document_id: doc_id }
      )
      matrix.destroy!
      raise
    end
  end
end
