module Autoselect
  module Otu
    # The existing Otu a Catalogue of Life result for a TaxonName yields, so
    # selecting (or creating ancestors for) a CoL name that already has an Otu
    # reuses it instead of making another. Shared by the OTU CoL levels, which
    # put it in their results' hook, and the OTU CoL create endpoint.
    #
    # When a TaxonName has several Otus, the one without a name of its own is
    # preferred, then the oldest.
    module ColExistingOtu

      CREATE_URL = '/otus/autoselect_col_create'.freeze

      # @param taxon_name_ids [Array<Integer, nil>]
      # @param project_id [Integer]
      # @return [Hash{Integer => Otu}] the existing Otu per TaxonName id, for
      #   those that have one
      def self.for_taxon_names(taxon_name_ids, project_id:)
        ids = taxon_name_ids.compact.uniq
        return {} if ids.empty?

        ::Otu.where(project_id:, taxon_name_id: ids)
          .sort_by { |otu| [otu.name.nil? ? 0 : 1, otu.id] }
          .group_by(&:taxon_name_id)
          .transform_values(&:first)
      end

      # @param taxon_name_id [Integer, nil]
      # @param project_id [Integer]
      # @return [Otu, nil]
      def self.for_taxon_name(taxon_name_id, project_id:)
        for_taxon_names([taxon_name_id], project_id:)[taxon_name_id]
      end

      # @param existing_otu [Otu, nil]
      # @return [Hash] the hook for an OTU CoL result; existing_id and
      #   existing_global_id are the Otu selecting the result yields without
      #   creating one (nil when there's none)
      def self.hook(existing_otu)
        {
          create_url: CREATE_URL,
          yields: 'otu_id',
          existing_id: existing_otu&.id,
          existing_global_id: existing_otu&.to_global_id&.to_s
        }
      end

    end
  end
end
