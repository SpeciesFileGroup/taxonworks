module Vendor
  module Gnfinder

    # A loose wrapper for https://github.com/GlobalNamesArchitecture/gnfinder/blob/master/lib/protob_pb.rb
    class Name

      # A hack at present, balance versus language and ongoing.  For now,
      # anything negative probability seems unlikely.
      LOW_PROBABILITY = 3.0

      attr_accessor :project_id

      # Alias for Name
      attr_accessor :found

      # params found_name [Gnfinder name]
      def initialize(found_name, project_id = [])
        @project_id = project_id
        @found = found_name
      end

      # Name helpers
      def name
        found.name
      end

      def verbatim
        found.verbatim
      end

      def words_start
        found.start
      end

      def words_end
        found.end
      end

      def words_before
        found.words_before || []
      end

      def words_after
        found.words_after || []
      end

      def classification_path
        found&.verification&.best_result&.classification_path&.split('|') || []
      end

      def classification_rank
        found&.verification&.best_result&.classification_ranks&.split('|') || []
      end

      # Verification helpers
      def best_result
        found.verification.best_result if is_verified?
      end

      def is_verified?
        found.verification && found.verification.best_result.match_type != :NONE
      end

      def is_low_probability?
        log_odds < LOW_PROBABILITY
      end

      def best_match_type
        best_result&.match_type
      end

      # Generic helpers

      def log_odds
        found.odds_log10
      end

      def is_new_name?
        %w{SP_NOV COMB_NOV SUBSP_NOV}.include?(found.annotation_nomen_type)
      end

      def protonym_name
        found.name.split(' ').last
      end

      # @return Array of TaxonName
      def matches
        TaxonName.where(project_id: project_id, cached: found.name)
          .or( TaxonName.where(project_id: project_id, cached_original_combination: found.name))
      end

      def is_in_taxonworks?
        matches.any?
      end

      def taxonworks_parent_name
        case found.cardinality
        when 0
          nil
        else
          # TODO: likely not right with sp. nov.
          found.name.split(' ')[-2]
        end
      end

      def taxonworks_parent
        return nil unless taxonworks_parent_name
        TaxonName.find_by(
          name: taxonworks_parent_name,
          project_id: project_id)
      end
    end

  end
end
