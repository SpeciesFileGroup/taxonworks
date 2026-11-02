module Autoselect
  module TaxonName
    # Creates TaxonName records (and CoL URI identifiers) from a Catalog of Life
    # selection.
    #
    # Receives an ordered list of rows (distal → proximal, i.e. kingdom first,
    # target last).
    # Each row represents one name to be created or an existing TaxonName to be
    # used as a parent. Rows with a taxonworks_id are already in the project; if
    # the row immediately above them was just inserted (a rank CoL reports that
    # TaxonWorks' real chain skipped), the existing record is reparented onto
    # it. Otherwise it's used as-is as a parent anchor and left untouched, and
    # it must already be under the row above it - if not, the rows don't
    # describe TaxonWorks' real lineage and the request is refused.
    #
    # @param rows [Array<Hash>] ordered distal→proximal; each hash has:
    #   col_name [String] — scientific name string from CoL
    #   col_rank [String] — human-readable rank (e.g. 'genus', 'species')
    #   col_id [String] — CoL taxon ID used to build the identifier URI
    #   taxonworks_id [Integer, nil] — existing TaxonName ID; if present, no
    #     creation occurs for this row
    #   col_authorship [String, nil] — combined author+year string from CoL
    #     (e.g. 'Linnaeus, 1758')
    #   col_year [String, nil] — year string extracted from CoL
    #     combinationAuthorship (target row only)
    #   col_status [String, nil] — CoL nomenclatural status (e.g. 'accepted',
    #     'synonym'); present on the target row only. A non-accepted target is
    #     never created (see #refuse_non_accepted).
    # @param col_code [String, nil] CoL nomenclatural code string: 'zoological',
    #   'botanical', 'bacterial', 'virus'. When present, rank resolution uses
    #   the corresponding lookup first. Falls back to trying all codes when nil
    #   or unrecognised.
    # @param project_id [Integer]
    # @param user_id [Integer]
    #
    # TODO: Rename to remove abbreviation
    #  CatalogueOfLifeCreator
    class ColCreator

      # Raised when any name in the creation loop fails validation.
      # Carries the row that triggered the failure for frontend highlighting.
      class CreationError < StandardError
        attr_reader :col_name, :col_id

        def initialize(message, col_name: nil, col_id: nil)
          super(message)
          @col_name = col_name
          @col_id = col_id
        end
      end

      # TODO:
      COL_BASE_URI = 'https://www.catalogueoflife.org/data/taxon/'.freeze

      def initialize(rows:, project_id:, user_id:, col_code: nil)
        @rows = rows
        @project_id = project_id.to_i
        @user_id = user_id.to_i
        @col_code = col_code.to_s.downcase.presence
      end

      # @return [Hash] { taxon_name_id: Integer, created_ids: Array<Integer> }
      # @raise [CreationError] if any record fails validation; the transaction
      #   is fully rolled back.
      def call
        parent_id = project_root_id
        # Whether parent_id is a row created in this call (a skipped
        # unknown-rank row leaves it as it was).
        parent_created = false
        created_ids = []

        matched_ids = @rows.filter_map { |row|
          row[:taxonworks_id].presence&.to_i
        }
        current_parent_ids = ::TaxonName
          .where(id: matched_ids, project_id: @project_id)
          .pluck(:id, :parent_id).to_h

        unknown_ids = matched_ids - current_parent_ids.keys
        if unknown_ids.any?
          raise CreationError.new("Unknown TaxonName id(s) for this project: #{unknown_ids.join(', ')}")
        end

        refuse_non_accepted()
        # An ancestor at a rank TaxonWorks doesn't have is skipped below, but
        # the target can't be: the result is whatever was created last, so
        # skipping it would hand back its parent as the record.
        refuse_unknown_target_rank()

        ::ActiveRecord::Base.transaction do
          @rows.each do |row|
            if row[:taxonworks_id].present?
              existing_id = row[:taxonworks_id].to_i

              if current_parent_ids[existing_id] != parent_id
                existing = ::TaxonName.where(project_id: @project_id).find(existing_id)

                # Only a row just created directly above (a rank CoL reports
                # that TaxonWorks' real chain skipped) reattaches this existing
                # record. Any other mismatch means the rows don't describe
                # TaxonWorks' real lineage (a stale modal, a hand-made
                # request) - refuse rather than move a curated record.
                if !parent_created
                  raise CreationError.new(
                    "#{existing.cached} isn't under the record above it in " \
                      'this request; the classification may have changed - ' \
                      'reopen and try again.',
                    col_name: row[:col_name],
                    col_id: row[:col_id]
                  )
                end

                begin
                  existing.update!(parent_id:)
                rescue ::ActiveRecord::RecordInvalid => e
                  raise CreationError.new(
                    "Reparenting #{existing.cached}: #{e.record.errors.full_messages.join(', ')}",
                    col_name: row[:col_name],
                    col_id: row[:col_id]
                  )
                end
              end

              parent_id = existing_id
              parent_created = false
              next
            end

            rank_class = resolve_rank_class(row[:col_rank])

            # Skip rows whose rank is entirely unknown to TaxonWorks — we cannot
            # create a valid Protonym without a rank_class (e.g. CoL-only ranks
            # like 'domain').
            next if rank_class.nil?

            author, year = ::Vendor::Colrapi::NameTranslation
              .split_authorship(row[:col_authorship], row[:col_year])

            begin
              tn = ::TaxonName.create!(
                type: 'Protonym',
                name: ::Vendor::Colrapi::NameTranslation
                  .protonym_name(row[:col_name], row[:col_rank]),
                parent_id:,
                rank_class:,
                verbatim_author: author,
                year_of_publication: year,
                project_id: @project_id,
                by: @user_id,
              )
            rescue ::ActiveRecord::RecordInvalid => e
              raise CreationError.new(
                e.record.errors.full_messages.join(', '),
                col_name: row[:col_name],
                col_id: row[:col_id]
              )
            end

            if row[:col_id].present?
              begin
                ::Identifier::Global::Uri::ChecklistBank.create!(
                  taxon_id: row[:col_id],
                  dataset_id: row[:dataset_id],
                  identifier_object: tn,
                  project_id: @project_id,
                  by: @user_id
                )
              rescue ::ActiveRecord::RecordInvalid => e
                raise CreationError.new(
                  "CoL identifier for #{row[:col_name]}: #{e.record.errors.full_messages.join(', ')}",
                  col_name: row[:col_name],
                  col_id: row[:col_id]
                )
              end
            end

            created_ids << tn.id
            parent_id = tn.id
            parent_created = true
          end
        end

        { taxon_name_id: parent_id, created_ids: }
      end

      private

      # Returns the TaxonName id of the project's Root node.
      def project_root_id
        ::Project.find(@project_id).root_taxon_name.id
      end

      # CoL gives a non-accepted name (synonym, misapplied, ...) only its
      # accepted name's classification, nothing of its own, so there's no
      # sound place to create it. The modal already disables Create for it;
      # this is the server-side guard. A row with a taxonworks_id isn't
      # created, so an existing name is still used.
      def refuse_non_accepted
        row = @rows.find do |r|
          r[:taxonworks_id].blank? && r[:col_status].present? &&
            !::Vendor::Colrapi::COL_ACCEPTED_STATUSES
              .include?(r[:col_status].to_s.downcase)
        end
        return if row.nil?

        raise CreationError.new(
          "#{row[:col_name]} is a #{row[:col_status]} in Catalogue of Life, " \
            "which has no classification of its own for it - it can't be " \
            'created from here.',
          col_name: row[:col_name],
          col_id: row[:col_id]
        )
      end

      def refuse_unknown_target_rank
        target = @rows.last
        return if target.nil? || target[:taxonworks_id].present?
        return if resolve_rank_class(target[:col_rank])

        raise CreationError.new(
          "Rank #{target[:col_rank]} isn't a TaxonWorks rank - " \
            "#{target[:col_name]} can't be created.",
          col_name: target[:col_name],
          col_id: target[:col_id]
        )
      end

      # Maps a human-readable CoL rank string to a TaxonWorks rank_class string.
      # Returns nil for unknown ranks.
      def resolve_rank_class(rank_string)
        ::Vendor::Colrapi.rank_class_for(rank_string, col_code: @col_code)
      end

    end
  end
end
