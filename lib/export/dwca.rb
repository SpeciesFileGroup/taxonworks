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

      download = ::Download::DwcArchive.create!(
        name: "DwC Archive generated at #{Time.now}.",
        description: 'A Darwin Core archive.',
        filename: name,
        request: request,
        expires: 2.days.from_now,
        total_records: record_scope.size # Was haveing problems with count() TODO: increment after when extensions are allowed.
      )

      # Note we pass a string with the record scope
      ::DwcaCreateDownloadJob.perform_later(download, core_scope: record_scope.to_sql)

      download
    end

    # @param klass [ActiveRecord class]
    #   e.g. CollectionObject
    # @param record_scope [An ActiveRecord scope]
    # @return Hash
    #   total: total records to expect
    #   start_time: the time indexing started
    #   sample: Array of object global ids spread across 10 (or fewer) intervals of the recordset
    #
    # When we re-index a large set of data then we run it in the background.
    # To determine when it is done we poll by the last record to be indexed.
    #
    def self.build_index_async(klass, record_scope)
      s = record_scope.order(:id)
      ::DwcaCreateIndexJob.perform_later(klass.to_s, sql_scope: s.to_sql)
      index_metadata(klass, s)
    end

    def self.index_metadata(klass, record_scope)
      a = record_scope.first&.to_global_id&.to_s
      b = record_scope.last&.to_global_id&.to_s

      t = record_scope.size # was haveing problems with count

      metadata = {
        total: t,
        start_time: Time.now,
        sample: [a, b].compact
      }

      if b && (t > 2)
        max = 8
        max = t if t < 8

        ids = klass
          .select('*')
          .from("(select id, type, ROW_NUMBER() OVER (ORDER BY id ASC) rn from (#{record_scope.to_sql}) b ) a")
          .where("a.rn % ((SELECT COUNT(*) FROM (#{record_scope.to_sql}) c) / #{max}) = 0")
          .limit(max)
          .collect{|o| o.to_global_id.to_s}

        metadata[:sample].insert(1, *ids)
      end

      metadata[:sample].uniq!
      metadata
    end
  end
end
