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

      # @return [Boolean]
      #   &exact=<"true"|"false">
      #   if 'true' then only #name = query_string results are returned (no fuzzy matching)
      attr_accessor :exact

      # Keys are method names. Existence of method is checked
      # before requesting the query
      QUERIES = {
        # OTU
        otu_name_exact: {priority: 1},
        autocomplete_exact_id: {priority: 1},
        autocomplete_identifier_cached_exact: {priority: 1},
        otu_name_start_match: {priority: 200},
        otu_name_similarity: {priority: 220},

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

      def initialize(string, project_id: nil, having_taxon_name_only: false, with_taxon_name: nil, exact: 'false')
        super(string, project_id:)
        @having_taxon_name_only = boolean_param({having_taxon_name_only:}, :having_taxon_name_only)
        @with_taxon_name = boolean_param({with_taxon_name:}, :with_taxon_name)

        # TODO: move to mode
        @exact = boolean_param({exact:}, :exact)
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

      # All records that meet the similarity cuttoff
      # - this is intended as a generic replacement for wildcarded results
      #
      # Observations:
      #   - was similarity(), experimenting with word_similarity
      #   - 3 letter matches are going to be low probability, matches kick in at 4
      #
      def otu_name_similarity
        base_query
          .where('otus.name % ?', query_string)
          .where( ApplicationRecord.sanitize_sql_array(["word_similarity('%s', otus.name) > 0.33", query_string]))
          .order('otus.name, length(otus.name)')
      end

      # @return [Scope]
      #   Pull the result of a TaxonName autocomplete. Maintain the order returned, and
      #   re-cast the result in terms of an OTU query. Expensive but maintaining order is key.
      def autocomplete_taxon_name
        taxon_names = Queries::TaxonName::Autocomplete.new(query_string, exact:, project_id:).autocomplete # an array, not a query

        ids = taxon_names.collect{|n| n.is_combination? ? n.cached_valid_taxon_name_id : n.id} # TODO: Experiment with :cached_valid_taxon_name_id) # We assume we want to land on Valid OTUs, but see #
        return nil if ids.empty?

        min = 10.0
        max = 20.0
        scale = (max - min) / ids.count.to_f

        # TODO: optimize *
        base_query.select("otus.*, ((#{min} + row_number() OVER ())::float * #{scale}) as priority") # small incrementing numbers for priority
          .joins("INNER JOIN ( SELECT unnest(ARRAY[#{ids.join(',')}]) AS id, row_number() OVER () AS row_num ) AS id_order ON otus.taxon_name_id = id_order.id")
          .order('id_order.row_num')
      end

      # Maintains valid_taxon_name_id needed for API.
      #
      # Considerations:
      #   otus -> taxon names -> valid taxon name_id <- otu can return more OTUs than the original query
      #      because there can be multiple OTUs for the valid name of an invalid original result.
      #      right now we pick the first valid OTU for the name with distinct on()
      #
      def api_autocomplete
        @with_taxon_name = true

        # This limit() has more impact now. Since all
        # names are loaded large matches can swamp exact names
        # before priority ordering is applied. May require tuning.
        otus = compact_priorities( autocomplete_base.limit(30) )

        otu_order = otus.map(&:id).uniq

        f = ::Otu.where(id: otu_order)
          .joins('left join taxon_names t1 on otus.taxon_name_id = t1.id')
          .joins('left join otus o2 on t1.cached_valid_taxon_name_id = o2.taxon_name_id')
          .select('distinct on (otus.id) otus.id, otus.name, otus.taxon_name_id, COALESCE(o2.id, otus.id) as otu_valid_id')

        f.sort_by.with_index { |item, idx| [(otu_order.index(item.id) || 999), (idx || 999)] }
      end


      def autocomplete_taxon_name_extended
        taxon_names = Queries::TaxonName::Autocomplete.new(query_string, exact:, project_id:).autocomplete # an array, not a query

        ids = taxon_names.collect{|n|
          [
            (n.is_combination? ? n.cached_valid_taxon_name_id : n.id), # Points to the OTU target, if there is one
            n.id,  # points to the label target
          ]
        }

        return ::Otu.none if ids.empty?

        ids.uniq!

        min = 10.0
        max = 20.0
        scale = (max - min) / ids.count.to_f

        # TODO: optimize *
        otus = base_query.select("otus.*, label_target_taxon_name_id, ((#{min} + row_number() OVER ())::float * #{scale}) as priority") # small incrementing numbers for priority
          .joins("INNER JOIN ( SELECT unnest(ARRAY[#{ids.map(&:first).join(',')}]) AS id, unnest(ARRAY[#{ids.map(&:last).join(',')}]) AS label_target_taxon_name_id, row_number() OVER () AS row_num ) AS id_order ON otus.taxon_name_id = id_order.id")
          .order('id_order.row_num')

        otus = scope_autocomplete(otus).includes(:taxon_name)

        otus
      end

      # An autocomplete result that permits displaying the TaxonName as originally matched.
      # @return [Array] of
      #    { otu:,  label_target:, otu_valid_id: } 
      #
      # Note that otu: is really only useful when displaying otus without &having_taxon_name_only=true.  We don't, for example make use 
      # of this element there.
      def api_autocomplete_extended
        otu_queries = QUERIES.dup
        otu_queries.delete(:autocomplete_taxon_name)

        base_otus = autocomplete_base(otu_queries).limit(30)
        taxon_name_otus = autocomplete_taxon_name_extended

        r = []

        base_otus.each do |o|
          r.push({
            otu: o, # contains priority
            label_target: o
          })
        end

        taxon_name_otus.each do |o|
          r.push({
            otu: o,
            label_target: (o.label_target_taxon_name_id ? ::TaxonName.find(o.label_target_taxon_name_id) : o.taxon_name )  # is o.taxon_name true?!
          })
        end

        # Keep a unique set of otu + label (to render)
        seen = Set.new

        # The compacted result
        compact = []

        r.each do |h|
          g = h[:label_target].id.to_s + h[:label_target].class.name
          m = [ h[:otu].id, g ]
          next if seen.include?( m )
          seen << m
          compact.push h
        end

        compact.sort!{|c,d| (c[:otu].priority || 999) <=> (d[:otu].priority || 999 )}

        # TODO: Refactor to remove extra query and assignment of otu_valid_id.  This is ugly.
        otu_order = compact.collect{|d| d[:otu].id}

        # Extra query is painful.
        f = ::Otu.where(id: otu_order)
          .joins('left join taxon_names t1 on otus.taxon_name_id = t1.id')
          .joins('left join otus o2 on t1.cached_valid_taxon_name_id = o2.taxon_name_id')
          .select('distinct on (otus.id) otus.id, otus.name, otus.taxon_name_id, COALESCE(o2.id, otus.id) as otu_valid_id')

        compact.each do |h|
          h[:otu_valid_id] = f.select{|j| j.id == h[:otu].id}.first.otu_valid_id
        end

        compact
      end

      #
      # Doesn't work for extended, as we can have the same OTU with different labels
      #
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

      def autocomplete_base(targets = QUERIES)
        queries = []

        targets.each do |q, p|
          if self.respond_to?(q)

            a = send(q)
            next if a.nil? # query has returned nil

            y = p[:priority]

            a = scope_autocomplete(a)

            a = a.select("otus.*, #{y} as priority") unless y.nil?

            queries.push a
          end
        end

        queries.compact!
        referenced_klass_union(queries).order('priority')
      end

      def scope_autocomplete(query)
        query = query.joins(:taxon_name) if with_taxon_name
        query = query.where.missing(:taxon_name) if with_taxon_name == false
        query = query.joins(:taxon_name).where(otus: {name: nil}) if having_taxon_name_only
        query
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
