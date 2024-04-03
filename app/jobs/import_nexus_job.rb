class ImportNexusJob < ApplicationJob
  queue_as :import_nexus

  def perform(*args)
    # Do something later
  end
end
