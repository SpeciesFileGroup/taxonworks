class ImportNexusJob < ApplicationJob
  queue_as :import_nexus
  include Lib::Vendor::NexusHelper

  def perform(nexus_doc_id, uid, project_id, title = nil)
    Current.user_id = uid
    Current.project_id = project_id
  end
end
