module Vendor
  module Gnfinder
    class Name
      attr_accessor :name, :verbatim, :match_start, :match_end, :words_before, :words_after

      # Uninomial Binomial PossibleBinomial Trinomial BayesUninomial BayesBinomial BayesTrinomial
      attr_accessor :match_type

      # Verification related
      attr_accessor :classification_path, :classification_rank, :data_source_title, :verification_type

      attr_accessor :project_id

      # @param found_name [Json] 
      def initialize(found_name, project_id = nil)
        @name = found_name[:name]
        @verbatim = found_name[:verbatim]
        @match_start = found_name[:start]
        @match_end = found_name[:end]
        @words_before = found_name[:words_before] || []
        @words_after = found_name[:words_after] || []

        @project_id = project_id

        @classification_path = found_name.dig(:verification, :BestResult, :classificationPath)&.split('|') || []
        @classification_rank = found_name.dig(:verification, :BestResult, :classificationRank)&.split('|') || []

        @verification_type = found_name.dig(:verification, :BestResult, :matchType)

        @match_type = found_name.dig(:type)

        @data_source_title = found_name.dig(:verification, :BestResult, :dataSourceTitle)
        @data_source_quality = found_name.dig(:verification, :BestResult, :dataSourceQuality)
      end

      def protonym_name
        name.split(' ').last
      end

      # @return Array of TaxonName
      def matches
        TaxonName.where(project_id: project_id, cached: name)
      end

      def is_verified?
        @verification_type && (@verification_type != :NONE)
      end

      def is_in_taxonworks?
        matches.any?
      end

      def taxonworks_parent_name
        case match_type
        when 'Binomial', 'Trinomial', 'BayesBinomial' 'BayesTrinomial'
          name.split(' ')[-2]
        else
          nil
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
