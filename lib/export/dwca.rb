require 'dwc_archive'

module Export
  module Dwca
    # Generates a DwC-A from database data

    # @param record_scope [ActiveRecord::Relation]
    #   a relation return DwcOccurrence records
    # @return [] 
    def self.download_async(record_scope, request = nil)
      name = "dwc-a_#{DateTime.now}.zip"

      download = ::Download.create!(
        name: "DwC Archive generated at #{Time.now}.",
        description: 'A Darwin Core archive.',
        filename: name,
        request: request,
        expires: 2.days.from_now
      )

      ::DwcaCreateDownloadJob.perform_later(download, core_scope: record_scope.to_sql)

      download
    end



  end
end
