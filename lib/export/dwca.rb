require 'dwc_archive'

module Export
  module Dwca

    # Version is a way to track dates where 
    # the indexing changed significantly such that all
    # or most of the index should be regenerated. 
    # To add a version use `Time.now` via IRB
    INDEX_VERSION = [
      '2021-08-29 21:16:02.903688 -0500' # First major refactor
    ]

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

      # Note we pass a string with the record scope
      ::DwcaCreateDownloadJob.perform_later(download, core_scope: record_scope.to_sql)

      download
    end

    # When we re-index a large set of data then we run it in the background.
    # To determine when it is done we poll by the last record to be indexed.
    # @return hash of global_ids
    #   The last object in the recordset has been sent on response
    def self.build_index_async(klass, record_scope)
      metadata = {
        total: record_scope.count,
        start_time: Time.now,
        sample: [
          record_scope.order(id: :ASC).limit(1).first&.to_global_id.to_s,
          record_scope.order(id: :DESC).limit(1).first&.to_global_id.to_s
        ]
      }

# CollectionObject.select('*').from('(select id, ROW_NUMBER() OVER (ORDER BY id ASC) rn from collection_objects) a').where('a.rn % ((SELECT COUNT(*) FROM collection_objects ) / 10) = 0').order(id: :asc).limit(8)

      ids = klass
        .select('*')
        .from("(select id, ROW_NUMBER() OVER (ORDER BY id ASC) rn from #{klass.table_name}) a")
        .where("a.rn % ((SELECT COUNT(*) FROM #{klass.table_name}) / 10) = 0")
        .order(id: :asc)
        .limit(8)
        .collect{|o| o.to_global_id.to_s}

      metadata[:sample].insert(1, *ids)
      ::DwcaCreateIndexJob.perform_later(klass.to_s, sql_scope: record_scope.order(:id).to_sql)
      metadata
    end

  end
end
