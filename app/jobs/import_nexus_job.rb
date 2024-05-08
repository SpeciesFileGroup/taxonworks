class ImportNexusJob < ApplicationJob
  queue_as :import_nexus
  include Lib::Vendor::NexusParserHelper

  def perform(nexus_doc_id, matrix, options, uid, project_id)
    Current.user_id = uid
    Current.project_id = project_id

    nf = document_to_nexus(nexus_doc_id, matrix, options)

    populate_matrix_with_nexus(
      nexus_doc_id,
      nf,
      matrix,
      options
    )
  end

  def document_to_nexus(nexus_doc_id, matrix, options)
    begin
      Vendor::NexusParser.document_id_to_nexus(nexus_doc_id)
    rescue => e
      if e.class == ActiveRecord::RecordNotFound
        # ExceptionNotifier ignores RecordNotFound, so use TW::Error instead.
        bt = e.backtrace
        e = TaxonWorks::Error.new(e.message)
        e.set_backtrace(bt)
      end

      ExceptionNotifier.notify_exception(e,
        data: {
          nexus_document_id: nexus_doc_id,
          matrix_id: matrix&.id,
          user_id: Current.user_id,
          project_id: Current.project_id
        }
        .merge(options)
      )

      matrix&.destroy!
      raise
    end
  end
end
