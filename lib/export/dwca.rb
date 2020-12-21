require 'dwc_archive'

module Export
  module Dwca

    # @param record_scope [ActiveRecord::Relation]
    #   a relation that returns DwcOccurrence records
    # @return [Download] 
    #   the download object containing the archive
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
