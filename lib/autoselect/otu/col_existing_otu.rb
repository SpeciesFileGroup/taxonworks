module Autoselect
  module Otu
    # The existing Otu a Catalogue of Life result for a TaxonName yields, so
    # selecting (or creating ancestors for) a CoL name that already has an Otu
    # reuses it instead of making another. Shared by the OTU CoL levels, which
    # put it in their results' hook, and the OTU CoL create endpoint.
    #
    # An existing Otu is used when it's the TaxonName's only Otu, or its one
    # Otu with no name of its own (named Otus alongside it are allowed - the
    # modal warns about them). Otherwise (several named Otus, or several
    # unnamed ones) which Otu is meant is the user's call: the result can't be
    # selected or have ancestors created, and the user picks the Otu directly
    # instead.
    module ColExistingOtu

      CREATE_URL = '/otus/autoselect_col_create'.freeze

      # Raised by .find_or_create_for when the user has to choose the Otu.
      class AmbiguousOtuError < StandardError; end

      # @param taxon_name_ids [Array<Integer, nil>]
      # @param project_id [Integer]
      # @return [Hash{Integer => Array<Otu>}] every Otu per TaxonName id, for
      #   those that have any
      def self.otus_by_taxon_name(taxon_name_ids, project_id:)
        ids = taxon_name_ids.compact.uniq
        return {} if ids.empty?

        ::Otu.where(project_id:, taxon_name_id: ids)
          .includes(:taxon_name)
          .order(:id)
          .group_by(&:taxon_name_id)
      end

      # @param otus [Array<Otu>] all of a TaxonName's Otus
      # @return [Otu, nil] the Otu a CoL result yields without the user
      #   choosing one: the only Otu, else the one Otu with no name of its own
      def self.selectable_otu(otus)
        return otus.first if otus.size == 1

        unnamed = otus.select { |otu| otu.name.blank? }
        unnamed.size == 1 ? unnamed.first : nil
      end

      # @param otus [Array<Otu>] all of the TaxonName's Otus, empty when it
      #   has none
      # @return [Hash] the hook for an OTU CoL result. existing_id,
      #   existing_global_id and otu_label are .selectable_otu (nil when
      #   there's none), existing_named whether it has a name of its own;
      #   otu_count is every Otu on the TaxonName
      def self.hook(otus)
        existing_otu = selectable_otu(otus)
        {
          create_url: CREATE_URL,
          yields: 'otu_id',
          existing_id: existing_otu&.id,
          existing_global_id: existing_otu&.to_global_id&.to_s,
          existing_named: existing_otu ? existing_otu.name.present? : false,
          taxon_name_id: otus.first&.taxon_name_id,
          otu_count: otus.size,
          otu_label: existing_otu &&
            ApplicationController.helpers.label_for_otu(existing_otu)
        }
      end

      # @param taxon_name_id [Integer]
      # @param project_id [Integer]
      # @param user_id [Integer]
      # @return [Otu] .selectable_otu, else a new Otu when the TaxonName has
      #   none
      # @raise [AmbiguousOtuError] when the TaxonName has Otus but none is
      #   selectable
      def self.find_or_create_for(taxon_name_id, project_id:, user_id:)
        otus = otus_by_taxon_name([taxon_name_id], project_id:)[taxon_name_id] || []

        if otus.empty?
          return ::Otu.create!(taxon_name_id:, project_id:, by: user_id)
        end

        otu = selectable_otu(otus)
        return otu if otu

        raise AmbiguousOtuError,
          "#{otus.first.taxon_name.cached} has #{otus.size} OTUs - select " \
          'the OTU you want directly'
      end

    end
  end
end
