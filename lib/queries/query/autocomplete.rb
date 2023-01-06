module Queries
  class Query::Autocomplete < Queries::Query

    include Arel::Nodes

    include Queries::Concerns::Identifiers

    # @return [Array]
    attr_accessor :project_id

    # @return [String, nil]
    #   the initial, unparsed value
    attr_accessor :query_string

    # parameters from keyword_args, used to group and pass along things like annotator params
    attr_accessor :options

    # limit based on size and potentially properties of terms
    attr_accessor :dynamic_limit

    # @param [Hash] args
    def initialize(string, project_id: nil, **keyword_args)
      @query_string = ::ApplicationRecord.sanitize_sql(string)&.delete("\u0000") # remove null bytes
      @options = keyword_args
      @project_id = project_id
      build_terms
    end

    def project_id
      [@project_id].flatten.compact
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
      if integers.any?
        table[:id].eq_any(integers)
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
        table[:project_id].eq_any(project_id)
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

    # @return [ActiveRecord::Relation]
    def autocomplete_cached
      if a = cached
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

    def autocomplete_common_name_like
      return nil if no_terms?
      base_query.joins(:common_names).where(common_name_wild_pieces.to_sql).limit(5)
    end

  end
end
