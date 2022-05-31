require 'dwc_archive'

# Library to create DwcA archives from TaxonWorks data.
#
# !! If changes are made to this or related Dwc files you should update the INDEX_VERSION constant.
#
module Export
  module Dwca

    # Version is a way to track dates where
    # the indexing changed significantly such that all
    # or most of the index should be regenerated.
    # To add a version use `Time.now` via IRB
    INDEX_VERSION = [
      '2021-10-12 17:00:00.000000 -0500',    # First major refactor
      '2021-10-15 17:00:00.000000 -0500',    # Minor  Excludes footprintWKT, and references to GeographicArea in gazetteer; new form of media links
      '2021-11-04 17:00:00.000000 -0500',    # Minor  Removes '|', fixes some mappings
      '2021-11-08 13:00:00.000000 -0500',    # PENDING: Minor  Adds depth mappings
      '2021-11-30 13:00:00.000000 -0500',    # Fix inverted long,lat 
      '2022-01-21 16:30:00.000000 -0500',    # basisOfRecord can now be FossilSpecimen; occurrenceId exporting; adds redundant time fields
      '2022-03-31 16:30:00.000000 -0500',    # collectionCode, occurrenceRemarks and various small fixes
      '2022-04-28 16:30:00.000000 -0500'     # add dwcOccurrenceStatus
    ]

    # @param record_scope [ActiveRecord::Relation]
    #   a relation that returns DwcOccurrence records
    # @return [Download]
    #   the download object containing the archive
    def self.download_async(record_scope, request = nil, predicate_extension_params: {})
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
      ::DwcaCreateDownloadJob.perform_later(download, core_scope: record_scope.to_sql, predicate_extension_params: predicate_extension_params)

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
    def self.build_index_async(klass, record_scope, predicate_extension_params: {} )
      s = record_scope.order(:id)
      ::DwcaCreateIndexJob.perform_later(klass.to_s, sql_scope: s.to_sql)
      index_metadata(klass, s)
    end

    def self.index_metadata(klass, record_scope)
      a = record_scope.first&.to_global_id&.to_s
      b = record_scope.last&.to_global_id&.to_s

      t = record_scope.size # was having problems with count

      metadata = {
        total: t,
        start_time: Time.now,
        sample: [a, b].compact
      }

      if b && (t > 2)
        max = 9
        max = t if t < 9

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
