module Queries

  # Requires significant refactor.
  #
  # To consider:
  # In general our optimization follows this pattern:
  #
  # a: Names that match exactly, full string
  # b: Names that match exactly, full Identifier (cached)
  # c: Names that match start of string exactly (cached), wildcard end of string, minimum 2 characters
  # d: Names that have a very high cuttoff            [good wildcard anywhere]
  # ? d.1: Names that have wildcard either side (limit to 2 characters).  Are results optimally better than d?
  # e: Names that have exact ID (internal) (will come to top automatically)
  # f: Names that match some special pattern (e.g. First letter, second name in taxon name search).  These
  #    may need higher priority in the stack.
  #
  # May also consider length, priority, similarity
  #
  class Query::Autocomplete < Queries::Query

    include Arel::Nodes

    include Queries::Concerns::Identifiers

    # @return [Array]
    attr_accessor :project_id

    # @return [String, nil]
    #   the initial, unparsed value, sanitized
    attr_accessor :query_string

    # Unused, to be used in future
    # limit based on size and potentially properties of terms
    attr_accessor :dynamic_limit

    # TODO: add mode
    # attr_accessor :mode

    # @return [ActiveRecord::Relation, nil]
    #   optional, restricts results to these records of referenced_klass.
    #   nil (default) is no restriction. Must be a relation of
    #   referenced_klass (or a subclass), e.g. `::CollectingEvent.where(...)`;
    #   any select on it is replaced with `select(:id)`. Anything else raises
    #   ArgumentError. See #apply_restriction.
    attr_accessor :restrict_to

    # The default #limit. Subclasses whose #autocomplete honours #limit set
    # their own.
    DEFAULT_LIMIT = 20

    # @param [Integer, nil]
    #   optional, how many results the caller wants. nil (default) is
    #   DEFAULT_LIMIT. Like #restrict_to, an autocomplete that delegates to
    #   another autocomplete passes it on, so that the inner autocomplete
    #   returns enough candidates for the outer one to fill its results.
    attr_writer :limit

    # @return [Hash, nil]
    #   optional, a store for the inner results of restricted
    #   #delegated_autocomplete calls. An autocomplete that creates several
    #   autocompletes delegating to the same inner autocomplete (e.g. one per
    #   side of a biological association) gives them all the same Hash, so
    #   the DELEGATED_DEPTH fetch runs once. nil (default) is no sharing.
    attr_accessor :delegated_results

    # @param [Hash] args
    def initialize(string, project_id: nil, restrict_to: nil, limit: nil, **keyword_args)
      @query_string = ::ApplicationRecord.sanitize_sql(string)&.delete("\u0000") # remove null bytes

      @project_id = project_id
      @restrict_to = restrict_to
      @limit = limit

      # should not need this
      # build_terms # TODO - should remove this for accessors
    end

    def project_id
      [@project_id].flatten.compact
    end

    # @return [Integer]
    #   the maximum number of results #autocomplete returns, the given
    #   limit or the subclass' DEFAULT_LIMIT
    def limit
      @limit || self.class::DEFAULT_LIMIT
    end

    # Apply #restrict_to to query. Subclasses should call this where they
    # assemble their individual queries (i.e. alongside where project_id is
    # applied), rather than in base_query, so that it covers queries not
    # built from base_query (e.g. referenced_klass.joins(:identifiers)).
    #
    # Use this when the caller only wants a subset of the model's records,
    # typically when one autocomplete delegates to another: restricting the
    # inner autocomplete to candidates the outer one can use keeps it fast,
    # and keeps unusable candidates from filling its result limits.
    #
    # The restriction is `table.id IN (<restrict_to>)`. Requiring a relation
    # of referenced_klass means the ids are always the model's own, and
    # `reselect(:id)` guarantees the single column an IN subquery needs.
    #
    # @param query [ActiveRecord::Relation] of referenced_klass
    # @return [ActiveRecord::Relation]
    def apply_restriction(query)
      return query if restrict_to.nil?

      r = restrict_to
      unless r.is_a?(ActiveRecord::Relation) && r.klass <= referenced_klass
        given = r.is_a?(ActiveRecord::Relation) ? r.klass.name : r.class.name
        raise ArgumentError,
          "restrict_to must be a relation of #{referenced_klass.name}, not #{given}"
      end

      query.where(table[:id].in(r.reselect(:id).arel))
    end

    # How deep a restricted #delegated_autocomplete takes its inner
    # autocomplete
    DELEGATED_DEPTH = 5000

    # The shortest query string a restricted #delegated_autocomplete runs
    # its inner autocomplete for
    DELEGATED_MINIMUM_LENGTH = 3

    # Run another model's (inner) autocomplete on behalf of this one. Use
    # it when an autocomplete delegates to another, instead of translating
    # #restrict_to for the inner model.
    #
    # Unrestricted, the inner autocomplete is simply run, #limit deep.
    #
    # Restricted, translating the restriction for the inner model is
    # relation-specific and easy to get subtly wrong (e.g. Otus -> the
    # TaxonNames, and Combinations, they resolve to), and pushing it into
    # each of the inner autocomplete's queries is expensive for large
    # restrictions (it's re-built in each query), so instead the inner
    # autocomplete is run once,
    # unrestricted, DELEGATED_DEPTH deep, and its results filtered by `keep`
    # (one query). Best effort: usable matches ranked below DELEGATED_DEPTH
    # (the least relevant) are missed. A LIMIT costs nothing for terms that
    # match fewer rows, so only broad terms pay for the depth; one deep fetch
    # was faster overall than starting shallower and deepening.
    #
    # Restricted, query strings shorter than DELEGATED_MINIMUM_LENGTH return
    # no inner results: they match so broadly that the DELEGATED_DEPTH
    # fetched are an arbitrary sample (largely unordered wildcard matches),
    # and the slowest to fetch.
    #
    # The DELEGATED_DEPTH results depend only on the inner autocomplete, not
    # on #restrict_to, so autocompletes given the same #delegated_results
    # share them, by `key`.
    #
    # The inner autocomplete must accept `limit:` and give its queries that
    # can return many rows a ranking order, so that the first
    # DELEGATED_DEPTH are the best ranked (see lib/queries/ARCHITECTURE.md).
    # So far only TaxonName autocomplete is used this way (its
    # #autocomplete_wildcard_joined_strings is unordered).
    #
    # @param build [Proc]
    #   given a limit (this autocomplete's #limit, not the inner
    #   autocomplete's default), returns the unrestricted inner autocomplete
    # @param keep [Proc]
    #   given inner results, returns those usable under #restrict_to, in
    #   order (e.g. those that map to an #apply_restriction record)
    # @param key [Array]
    #   everything, other than the limit, that `build` passes the inner
    #   autocomplete, i.e. what its results depend on
    # @return [Array]
    #   inner results, when restricted at most #limit of them
    def delegated_autocomplete(build:, keep:, key:)
      inner = build.call(limit)
      return inner.autocomplete if restrict_to.nil?
      return [] if query_string.to_s.length < DELEGATED_MINIMUM_LENGTH

      inner.limit = DELEGATED_DEPTH
      results = (delegated_results || {})[[inner.class, *key]] ||= inner.autocomplete
      keep.call(results).first(limit)
    end

    # Order query by the position of `column` in `ids`, e.g. another
    # autocomplete's ranked results, so that a limit keeps the best matches.
    # Ties (e.g. several records per id) are broken by #table id.
    #
    # @param query [ActiveRecord::Relation] of referenced_klass
    # @param column [String]
    #   a qualified column holding the ids, e.g. 'otus.id'
    # @param ids [Array]
    #   not empty, in rank order
    # @return [ActiveRecord::Relation]
    def order_by_id_rank(query, column, ids)
      query.order(Arel.sql(
        "array_position(ARRAY[#{ids.map(&:to_i).join(',')}], #{column}), #{table.name}.id"
      ))
    end

    # The most ids #asserted_object_restriction passes literally
    LITERAL_RESTRICTION_MAX = 1000

    # @param asserted [ActiveRecord::Relation]
    #   of referenced_klass, the asserted records of one object type
    # @param object_klass [Class]
    # @param object_id_column [String]
    #   the column of `asserted` holding the object ids
    # @return [ActiveRecord::Relation, nil]
    #   the object_klass records that have an `asserted` record, nil if
    #   there are none
    def asserted_object_restriction(asserted, object_klass, object_id_column)
      # The restriction is re-applied in every query of the object
      # autocomplete, and of those it delegates to (e.g. BA -> Otu/CO/... ->
      # TaxonName, dozens of queries): when there are few ids, passing them
      # literally is much cheaper than re-evaluating the subquery in each;
      # when there are many, the subquery is cheaper. Only the caller can
      # tell cheaply (one pluck here); checking the size at every level of
      # the chain costs more than it saves.
      ids = asserted.distinct
        .limit(LITERAL_RESTRICTION_MAX + 1).pluck(object_id_column)
      return nil if ids.empty?

      if ids.size <= LITERAL_RESTRICTION_MAX
        object_klass.where(id: ids)
      else
        object_klass.where(id: asserted.select(object_id_column))
      end
    end

    # For autocompletes of records asserting something about a polymorphic
    # object (e.g. AssertedDistribution, AssertedEnvironment): match the
    # objects of `object_type` with their own autocomplete, then return the
    # asserted records of those objects, in the object autocomplete's rank
    # order.
    #
    # The combinatorics are not great for joining each object autocomplete
    # option with the asserted records directly, so the object autocomplete
    # is run restricted to objects that have asserted records (in
    # #project_id, within #restrict_to). This keeps it fast and keeps
    # objects without (usable) asserted records from filling its result
    # limit: every one has one, so #limit of them can fill the results.
    #
    # @param object_type [String]
    #   e.g. 'BiologicalAssociation'
    # @param object_autocomplete_class [Class]
    #   accepting `restrict_to:` and `limit:`
    # @param object_association [Symbol]
    #   the polymorphic association, e.g. :asserted_distribution_object
    # @return [ActiveRecord::Relation, nil]
    #   of referenced_klass, at most #limit, nil if there are no matches
    def asserted_object_autocomplete(object_type:, object_autocomplete_class:, object_association:)
      type_column = "#{object_association}_type"
      id_column = "#{object_association}_id"

      asserted = referenced_klass.where(type_column => object_type)
      asserted = asserted.where(project_id:) if project_id.present?
      asserted = apply_restriction(asserted)

      objects = asserted_object_restriction(asserted, object_type.constantize, id_column)
      return nil if objects.nil?

      object_ids = object_autocomplete_class
        .new(query_string, project_id:, restrict_to: objects, limit:)
        .autocomplete.map(&:id)
      return nil if object_ids.empty?

      order_by_id_rank(
        asserted.where(id_column => object_ids), "#{table.name}.#{id_column}", object_ids
      ).limit(limit)
    end

    # @return [Scope]
    # stub
    # TODO: deprecate? probably unused
    def scope
      where('1 = 2')
    end

    # @return [Array]
    def years
      Utilities::Strings.years(query_string)
    end

    # @return [String, nil]
    def year_letter
      Utilities::Strings.year_letter(query_string)
    end

    # @return [Array]
    #   of strings representing integers
    def integers
      Utilities::Strings.integers(query_string)
    end

    # @return [Array<Integer>]
    #   Array of integers parsed from `query_string` that fit within the
    #   4-byte SQL integer range (1 to 2_147_483_647)
    def safe_integers
      integers
        .map(&:to_i)
        .select { |i| i.between?(1, 2_147_483_647) }
    end

    # @return [Boolean]
    def only_integers?
      Utilities::Strings.only_integers?(query_string)
    end

    # @return [Array]
    #   if 1-5 alphanumeric_strings, those alphabetic_strings wrapped in wildcards, else none.
    #  Used in *unordered* AND searches
    def fragments
      a = alphanumeric_strings
      if a.size > 0 && a.size < 6
        a.collect{|a| "%#{a}%"}
      else
        []
      end
    end

    # @return [Array]
    #   if 1-5 alphabetic_strings, those alphabetic_strings wrapped in wildcards, else none.
    #  Used in *unordered* AND searches
    def string_fragments
      a = alphabetic_strings
      if a.size > 0 && a.size < 6
        a.collect{|a| "%#{a}%"}
      else
        []
      end
    end

    # @return [Array]
    #   split on whitespace
    # TODO: used?!
    def pieces
      query_string.split(/\s+/)
    end

    # @return [Array]
    def wildcard_wrapped_integers
      integers.collect{|i| "%#{i}%"}
    end

    # @return [Array]
    def wildcard_wrapped_years
      years.collect{|i| "%#{i}%"}
    end

    # @return [Integer]
    def dynamic_limit
      limit = 10
      case query_string.length
      when 0..3
        limit = 20
      else
        limit = 100
      end
      limit
    end

    # @return [Scope]
    def parent_child_join
      table.join(parent).on(table[:parent_id].eq(parent[:id])).join_sources
    end

    # Match at two levels, for example, 'wa te" will match "Washington Co., Texas"
    # @return [Arel::Nodes::Grouping]
    def parent_child_where
      a,b = query_string.split(/\s+/, 2)
      return table[:id].eq(-1) if a.nil? || b.nil?
      table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
    end

    # @return [Arel::Nodes, nil]
    #   used in or_clauses
    def with_id
      if safe_integers.any?
        table[:id].in(safe_integers)
      else
        nil
      end
    end

    # @return [Arek::Npdes, nil]
    #   used in or_clauses, match on id only if integers alone provided.
    def only_ids
      if only_integers?
        with_id
      else
        nil
      end
    end

    # @return [Arel::Nodes::Matches]
    def named
      table[:name].matches_any(terms) if terms.any?
    end

    # @return [Arel::Nodes::Matches]
    def exactly_named
      table[:name].eq(query_string) if query_string.present?
    end

    # @return [Arel::Nodes::TableAlias]
    #  used in heirarchy joins
    def parent
      table.alias
    end

    # TODO: nil/or clause this
    # @return [Arel::Nodes::Equality]
    def with_project_id
      if project_id.present?
        table[:project_id].in(project_id)
      else
        nil
      end
    end

    # @return [Arel::Nodes::Matches]
    def with_cached
      table[:cached].eq(query_string)
    end

    # @return [Arel::Nodes::Matches]
    def with_cached_like
      table[:cached].matches(start_and_end_wildcard)
    end

    # match ALL wildcards, but unordered, if 2 - 6 pieces provided
    # @return [Arel::Nodes::Matches]
    def match_wildcard_end_in_cached
      table[:cached].matches(end_wildcard)
    end

    # match ALL wildcards, but unordered, if 2 - 6 pieces provided
    # @return [Arel::Nodes::Matches]
    def match_wildcard_in_cached
      b = fragments
      return nil if b.empty?
      table[:cached].matches_all(b)
    end

    # @return [Arel::Nodes::Grouping]
    def combine_or_clauses(clauses)
      clauses.compact!
      raise TaxonWorks::Error, 'combine_or_clauses called without a clause, ensure at least one exists' unless !clauses.empty?
      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end

    #
    # Autocomplete
    #
    # !! All methods must return nil of a scope

    # @return [Array]
    #   default the autocomplete result to all
    #   TODO: eliminate
    def autocomplete
      return [] if query_string.blank?
      all.to_a
    end

    # @return [ActiveRecord::Relation]
    def autocomplete_exact_id
      if i = ::Utilities::Strings::only_integer(query_string)
        base_query.where(id: i).limit(1)
      else
        nil
      end
    end

    # @return [ActiveRecord::Relation]
    def autocomplete_ordered_wildcard_pieces_in_cached
      return nil if no_terms?
      base_query.where(match_ordered_wildcard_pieces_in_cached.to_sql)
    end

    # @return [ActiveRecord::Relation]
    #   removes years/integers!
    def autocomplete_cached_wildcard_anywhere
      a = match_wildcard_in_cached
      return nil if a.nil?
      base_query.where(a.to_sql)
    end

    # @return [ActiveRecord::Relation, nil]
    #   cached matches full query string wildcarded
    # TODO: Used in taxon_name, source, identifier
    def cached_facet
      return nil if no_terms?
      # TODO: or is redundant with terms in many cases
      (table[:cached].matches_any(terms)).or(match_ordered_wildcard_pieces_in_cached)
    end

    # @return [ActiveRecord::Relation]
    def autocomplete_cached
      if a = cached_facet
        base_query.where(a.to_sql).limit(20)
      else
        nil
      end
    end

    # @return [ActiveRecord::Relation]
    def autocomplete_exactly_named
      return nil if no_terms?
      base_query.where(exactly_named.to_sql).limit(20)
    end

    # @return [ActiveRecord::Relation]
    def autocomplete_named
      return nil if no_terms?
      base_query.where(named.to_sql).limit(20)
    end

    def common_name_table
      ::CommonName.arel_table
    end

    def common_name_name
      common_name_table[:name].eq(query_string)
    end

    def common_name_wild_pieces
      common_name_table[:name].matches(wildcard_pieces)
    end

    def autocomplete_common_name_exact
      return nil if no_terms?
      base_query.joins(:common_names).where(common_name_name.to_sql).limit(1)
    end

    # TODO: GIN/similarity
    def autocomplete_common_name_like
      return nil if no_terms?
      base_query.joins(:common_names).where(common_name_wild_pieces.to_sql).limit(5)
    end

    # Calculate the levenshtein distance for a value across multiple columns, and keep the smallest.
    #
    # @param fields [Array] the table column names to take strings from
    # @param value [String] the string to calculate distances to
    def least_levenshtein(fields, value)
      levenshtein_sql = fields.map {|f| levenshtein_distance(f, value).to_sql }
      Arel.sql("least(#{levenshtein_sql.join(", ")})")
    end

    # TODO: not used
    # @return [Arel:Nodes]
    # def or_and
    #   a = or_clauses
    #   b = and_clauses

    #   if a && b
    #     a.and(b)
    #   else
    #     a
    #   end
    # end

  end
end
