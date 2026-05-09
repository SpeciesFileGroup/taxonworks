# lib/autoselect/taxon_name/levels/catalogue_of_life.rb
module Autoselect
  module TaxonName
    module Levels
      class CatalogueOfLife < ::Autoselect::Level
        include ::Autoselect::Levels::ColRecordInfo

        def key
          :catalogue_of_life
        end

        def label
          'Catalogue of Life'
        end

        def description
          'Search the Catalogue of Life for matching names. Returns external results with alignment data for confirmation.'
        end

        def external?
          true
        end

        def record_label(record)
          record.cached.to_s
        end

        def record_label_html(record)
          record.cached.to_s
        end

        # @param term [String]
        # @param project_id [Integer, nil]
        # @param dataset_id [String, nil] CoL dataset ID from user preferences; falls back to default when nil
        # @return [Array<OpenStruct>] pseudo-records compatible with TaxonName autoselect format_results
        def call(term:, operator: nil, project_id: nil, user_id: nil, dataset_id: nil, **_kwargs)
          raw = ::Vendor::Colrapi.search(term, dataset_id:)
          results = raw['result'] || []
          return [] if results.empty?

          results.map do |col_result|
            # Flat nameusage structure: 'id', 'status', 'name' hash, 'label', 'labelHtml'
            col_name   = col_result.dig('name', 'scientificName') || col_result['label']
            col_rank   = col_result.dig('name', 'rank')&.downcase
            col_name   = ::Vendor::Colrapi.extract_subgenus_name(col_name) if col_rank == 'subgenus'
            col_status = col_result['status']
            col_key    = col_result['id']
            extension  = ::Vendor::Colrapi.build_extension(col_result, project_id, dataset_id:)

            # Annotate whether the target name already exists in this project so the
            # confirmation modal can offer "Select" instead of "Create" when nothing
            # needs to be created.
            if project_id.present?
              existing = ::TaxonName.where(project_id:, cached: col_name).first
              if existing
                extension = extension.merge(
                  target_taxonworks_id: existing.id,
                  target_global_id: existing.to_global_id.to_s
                )
              end
            end

            # Flag when the target's rank is not resolvable in TaxonWorks (e.g. 'domain').
            # ColCreator silently skips such rows, so the modal needs to know up-front.
            extension = extension.merge(target_rank_unknown: true) unless rank_resolvable?(col_rank)

            OpenStruct.new(
              id: nil,
              cached: col_name,
              name: col_name,
              rank_string: nil,
              cached_valid_taxon_name_id: nil,
              _col_extension: extension
            )
          end
        end

        private

        def rank_resolvable?(rank_string)
          return false if rank_string.blank?
          r = rank_string.to_s.downcase
          [:ICZN_LOOKUP, :ICN_LOOKUP, :ICNP_LOOKUP, :ICVCN_LOOKUP].any? do |key|
            Object.const_get("::#{key}")[r].present?
          end
        end

      end
    end
  end
end
