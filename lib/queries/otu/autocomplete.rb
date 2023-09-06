require Rails.root.to_s + '/lib/queries/taxon_name/autocomplete'

module Queries
  module Otu

    class Autocomplete < Query::Autocomplete

      # @return Boolean
      #   true - ignores search on Otu#name
      #   false,nil - no effect
      attr_accessor :having_taxon_name_only

      def initialize(string, project_id: nil, having_taxon_name_only: false)
        super(string, project_id:)
        @having_taxon_name_only = boolean_param({having_taxon_name_only:}, :having_taxon_name_only)
      end

      def base_query
        ::Otu.where(project_id:).includes(:taxon_name)
      end

      # Top 10 most similar records
      def autocomplete_name_only(rank = 1)
        ::Otu
        .select(ApplicationRecord.sanitize_sql(['otus.*, ? AS rank, similarity(?, name) AS sml', rank, query_string]))
        .where(taxon_name_id: nil)
        .order('sml DESC, name')
        .limit(10)
      end

      # All records that meet the similarity cuttoff (.3 by default)
      def autocomplete_name_cutoff(rank = 1)
        ::Otu
        .select(ApplicationRecord.sanitize_sql(['otus.*, ? AS rank, similarity(?, name) AS sml', rank, query_string]))
        .where('name % ?', query_string)
        .order('sml DESC, name')
      end

      # All records without taxon names that meet the similarity cutoff
      def autocomplete_name_only_cutoff(rank = 1)
        ::Otu
        .select(ApplicationRecord.sanitize_sql(['otus.*, ? AS rank, similarity(?, name) AS sml', rank, query_string]))
        .where(taxon_name_id: nil)
        .where('name % ?', query_string)
        .order('sml DESC, name')
      end

      # Similarity with cutoff on taxon_name#cached (TODO: should be a TaxonName::Autocomplete method)
      def autocomplete_taxon_name_cached_cutoff(rank = 1)
        ::Otu.joins(:taxon_name)
        .select(ApplicationRecord.sanitize_sql(['otus.*, ? AS rank, similarity(?, cached) AS sml', rank, query_string]))
        .where('cached % ?', query_string)
        .order('sml DESC, cached')
      end

      # Maintains valid_taxon_name_id needed for API. Much over-kill on intermediate queries.
      def api_autocomplete
        @having_taxon_name_only = true

        otus = autocomplete # array

        otu_order = otus.map(&:id)

        taxon_names = ::TaxonName.where(project_id:, id: otus.map(&:taxon_name_id)) # pertinent names

        s = 'WITH tns AS (' + taxon_names.that_is_valid.to_sql + ') ' +
           ::Otu.joins('JOIN tns AS tns_o ON tns_o.id = otus.taxon_name_id')
             .select('otus.*, otus.id as otu_valid_id')
             .to_sql

        a = ::Otu.select('otus.*, otu_valid_id').from('(' + s + ') as otus')

        # Invalid name matches
        t = 'WITH tns_invalid AS (' + taxon_names.that_is_invalid.to_sql + ') ' +
          ::Otu.joins('JOIN tns_invalid as tns_invalid1 ON tns_invalid1.id = otus.taxon_name_id')
           .joins('LEFT JOIN otus AS otus1 ON tns_invalid1.cached_valid_taxon_name_id = otus1.taxon_name_id')
           .select('DISTINCT ON(otus1.id) otus.*, otus1.id AS otu_valid_id')
           .to_sql

        b = ::Otu.select('otus.*, otu_valid_id').from('(' + t + ') as otus')

        u = ::Otu.from("( (#{a.to_sql}) UNION (#{b.to_sql})) as otus")
        f = ::Otu.from('(' + u.to_sql + ') as otus').sort_by.with_index { |item, idx| [(otu_order.index(item.id) || 999), (idx || 999)] }

        f

        # taxon_names = Queries::TaxonName::Autocomplete.new(query_string, project_id:).autocomplete_combined_gin
        # .where(project_id:)

        # # Valid only tns don't need to map to invalid OTUs

        # s = 'WITH tns AS (' + taxon_names.that_is_valid.to_sql + ') ' +
        #     ::Otu.joins('JOIN tns AS tns_o ON tns_o.id = otus.taxon_name_id')
        #       .select('otus.*, otus.id as otu_valid_id, tns_o.sml_t AS sml_o_x')
        #       .to_sql

        #  a = ::Otu.select('otus.*, sml_o_x as sml_o_z, otu_valid_id').from('(' + s + ') as otus')

        #  # Invalid name matches

        #  t = 'WITH tns_invalid AS (' + taxon_names.that_is_invalid.to_sql + ') ' +
        #  ::Otu.joins('JOIN tns_invalid as tns_invalid1 ON tns_invalid1.id = otus.taxon_name_id')
        #     .joins('LEFT JOIN otus AS otus1 ON tns_invalid1.cached_valid_taxon_name_id = otus1.taxon_name_id')
        #     .select('DISTINCT ON(otus1.id) otus.*, otus1.id AS otu_valid_id, tns_invalid1.sml_t AS sml_o_y ')
        #     .to_sql

        # b = ::Otu.select('otus.*, sml_o_y as sml_o_z, otu_valid_id').from('(' + t + ') as otus')

        # u = ::Otu.from("( (#{a.to_sql}) UNION (#{b.to_sql})) as otus")

        # ::Otu.from('(' + u.to_sql + ') as otus').order('sml_o_z DESC').limit(20)
      end

      # @return [Scope]
      def autocomplete_via_taxon_name_autocomplete
        taxon_names = Queries::TaxonName::Autocomplete.new(query_string, project_id:).autocomplete # an array, not a query

        q = base_query

        if having_taxon_name_only
          q = q.joins(:taxon_name).where(otus: {name: nil})
        else

        end

        ( having_taxon_name_only ? base_query : base_query.left_joins(:taxon_name)) # ::Otu.where(name: nil)
          .where(taxon_name_id: taxon_names.map(&:id))
      end

      def base_queries
        queries = []

        queries << autocomplete_exactly_named unless having_taxon_name_only

        queries += [
          autocomplete_exact_id,
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
        ]

        queries << autocomplete_named unless having_taxon_name_only

        queries += [
          autocomplete_name_cutoff(1),
          # autocomplete_name_only_cutoff(1),
          autocomplete_taxon_name_cached_cutoff(2),

          # autocomplete_name_only(3), <- always returns some record, which prevents New OTU
          autocomplete_via_taxon_name_autocomplete,
          # autocomplete_identifier_cached_like, # this query takes 20 time longer to complete than any other.
          # autocomplete_common_name_exact,
          # autocomplete_common_name_like
        ]

        queries.compact!

        return [] if queries.nil?
        updated_queries = []

        queries.each_with_index do |q ,i|
          a = q.where(project_id:) if project_id.present?
          a ||= q
          updated_queries[i] = a
        end

        updated_queries
      end

      # @return [Array]
      def autocomplete
        result = []
        base_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 39
        end
        result[0..39]
      end
    end
  end
end
