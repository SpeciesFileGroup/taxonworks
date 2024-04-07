class ImportNexusJob < ApplicationJob
  queue_as :import_nexus

  def perform(nexus_doc_id, uid, project_id, title = nil)

  end
end
