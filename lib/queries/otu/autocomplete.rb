require Rails.root.to_s + '/lib/queries/taxon_name/autocomplete'

module Queries
  module Otu

    # See Query::Autocomplete for optimization strategy per name.
    # There are 4 classes of name, each which has the same strategy: OTU name, Original TaxonName, TaxonName, CommonName
    # We then apply a global priority pulling the best names from each sub-strategy
    # to the top.
    #
    class Autocomplete < Query::Autocomplete

      # @return Boolean, nil
      #   true - only return Otus with `name` = nil
      #   false,nil - no effect
      attr_accessor :having_taxon_name_only

      # @return Boolean, nil
      #   true - OTU must have taxon name
      #   false - OTU must not have taxon name
      #   nil - ignored
      attr_accessor :with_taxon_name

      # Keys are method names. Existence of method is checked
      # before requesting the query
      QUERIES = {
        # OTU
        otu_name_exact: {priority: 1},
        otu_name_start_match: {priority: 200},
        otu_name_similarity: {priority: 220},
        autocomplete_exact_id: {priority: 1},
        autocomplete_identifier_cached_exact: {priority: 1},

        # TaxonName
        autocomplete_taxon_name: {priority: nil}, # Priority is slotted from 10 .. 20
        # These are all approximately covered in the blanket taxon_name autocomplete
        # taxon_name_name_exact: {priority: 10},
        # taxon_name_identifier_exact: {priority: 10},
        # taxon_name_name_start_match: {priority: 100},
        # taxon_name_name_high_cuttoff: {priority: 200},

        # CommonName
        # These should all be covered/moved to common_name_autocomplete,
        autocomplete_common_name_exact: {priority: 100},
        autocomplete_common_name_like: {priority: 1000}
        # common_name_identifier_exact: {priority: 10},
        # common_name_name_start_match: {priority: 100},
        # common_name_name_similarity: {priority: 200},
      }.freeze

      def initialize(string, project_id: nil, having_taxon_name_only: false, with_taxon_name: nil)
        super(string, project_id:)
        @having_taxon_name_only = boolean_param({having_taxon_name_only:}, :having_taxon_name_only)
        @with_taxon_name = boolean_param({with_taxon_name:}, :with_taxon_name)
      end

      def base_query
        q = ::Otu.all
        q = q.where(project_id:) if project_id.any?
        q
      end

      def otu_name_exact
        base_query.where(otus: {name: query_string})
      end

      def otu_name_start_match
        base_query.where('otus.name ilike ?', query_string + '%')
      end

      # All records that meet the similarity cuttoff (.3 by default)
      def otu_name_similarity
        base_query
        .where('otus.name % ?', query_string)
        .where( ApplicationRecord.sanitize_sql("similarity('#{query_string}', otus.name) > 0.7"))
        .order('otus.name, length(otus.name)')
      end

      # @return [Scope]
      #   Pull the result of a TaxonName autocomplete. Maintain the order returned, and
      #   re-cast the result in terms of an OTU query. Expensive but maintain order is key.
      def autocomplete_taxon_name
        taxon_names = Queries::TaxonName::Autocomplete.new(query_string, project_id:).autocomplete # an array, not a query

        ids = taxon_names.map(&:id) # maintain order
        return nil if ids.empty?

        min = 10.0
        max = 20.0
        scale = (max - min) / ids.count.to_f

        base_query.select("otus.*, ((#{min} + row_number() OVER ())::float * #{scale}) as priority") # small incrementing numbers for priority
        .joins("INNER JOIN ( SELECT unnest(ARRAY[#{ids.join(',')}]) AS id, row_number() OVER () AS row_num ) AS id_order ON otus.taxon_name_id = id_order.id")
        .order('id_order.row_num')
      end

      # Maintains valid_taxon_name_id needed for API. Much over-kill on intermediate queries,
      # needs refactor.
      #
      # TODO:
      #   otus -> taxon names -> valid taxon name_id <- otu can return more OTUs than the original query
      #      becuase there can be multiple OTUs for the valid name of an invalid original result
      #
      #  This means we can just go from an invalid otu to it's valid target, we'd have to select the first
      #  target (distinct on).
      #
      def api_autocomplete
        @with_taxon_name = true

        # This limit() has more impact now. Since all
        # names are loaded large matches can swamp exact names
        # before priority ordering is applied. May require tuning.
        otus = compact_priorities( autocomplete_base.limit(30) )

        otu_order = otus.map(&:id)

        taxon_names = ::TaxonName.where(project_id:, id: otus.map(&:taxon_name_id).uniq) # pertinent names

        s = 'WITH tns AS (' + taxon_names.that_is_valid.to_sql + ') ' +
           ::Otu.joins('JOIN tns AS tns_o ON tns_o.id = otus.taxon_name_id')
             .where(otus: {id: otu_order})
             .select('DISTINCT ON(otus.id) otus.*, otus.id as otu_valid_id')
             .to_sql

        a = ::Otu.select('otus.*, otu_valid_id').from('(' + s + ') as otus')

        # Invalid name matches
        t = 'WITH tns_invalid AS (' + taxon_names.that_is_invalid.to_sql + ') ' +
          ::Otu.joins('JOIN tns_invalid as tns_invalid1 ON tns_invalid1.id = otus.taxon_name_id')
           .where(otus: {id: otu_order})
           .joins('LEFT JOIN otus AS otus1 ON tns_invalid1.cached_valid_taxon_name_id = otus1.taxon_name_id')
           .select('DISTINCT ON(otus1.id) otus.*, otus1.id AS otu_valid_id')
           .to_sql

        b = ::Otu.select('otus.*, otu_valid_id').from('(' + t + ') as otus')

        # TODO? see alternate ordering approach in SQL in autocomplete_taxon_name
        u = ::Otu.from("( (#{a.to_sql}) UNION (#{b.to_sql})) as otus")
        f = ::Otu.from('(' + u.to_sql + ') as otus')

        f.sort_by.with_index { |item, idx| [(otu_order.index(item.id) || 999), (idx || 999)] }
      end

      def compact_priorities(otus)
        # Mmmmarg!
        # We may have the same name at different priorities, strike all but the highest/first.
        r = []
        i = {}
        otus.each do |o|
          next if i[o.id]
          r.push o
          i[o.id] = true
        end
        r
      end

      def autocomplete
        compact_priorities( autocomplete_base.limit(40) )
      end

      def autocomplete_base
        queries = []

        QUERIES.each do |q, p|
          if self.respond_to?(q)

            a = send(q)
            next if a.nil? # query has returned nil

            y = p[:priority]

            a = a.joins(:taxon_name) if with_taxon_name
            a = a.where.missing(:taxon_name) if with_taxon_name == false
            a = a.joins(:taxon_name).where(otus: {name: nil}) if having_taxon_name_only

            a = a.select("otus.*, #{y} as priority") unless y.nil?

            queries.push a
          end
        end

        queries.compact!
        referenced_klass_union(queries).order('priority')
      end

       # # @return [Array]
       # def autocomplete
       #   result = []
       #   base_queries.each do |q|
       #     result += q.to_a
       #     result.uniq!
       #     break if result.count > 39
       #   end
       #   result[0..39].uniq
       # end

    end
  end
end
