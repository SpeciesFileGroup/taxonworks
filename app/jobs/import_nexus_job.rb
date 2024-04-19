class ImportNexusJob < ApplicationJob
  queue_as :import_nexus
  include Lib::Vendor::NexusHelper

  def perform(nexus_doc_id, uid, project_id, title = nil)

  end
end
