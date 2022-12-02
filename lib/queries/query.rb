# A module for composing Queries.
#
# For insights, etc. see:
#  http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
#  https://github.com/rails/arel
#  http://robots.thoughtbot.com/using-arel-to-compose-sql-queries
#  https://github.com/rails/arel/blob/master/lib/arel/predications.rb
#
#  And this:
#    http://blog.arkency.com/2013/12/rails4-preloading/
#    User.includes(:addresses).where("addresses.country = ?", "Poland").references(:addresses)
#
# TODO: Define #all as a stub (Array or AR)
#
module Queries
  class Query
    include Arel::Nodes

    include Queries::Concerns::Identifiers

    # @return [String, nil]
    #   the initial, unparsed value
    attr_accessor :query_string

    attr_accessor :terms
    attr_accessor :project_id

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

    # @return [Array]
    #   the results of the query as ActiveRecord objects
    # TODO: deprecate? probably unused
    def result
      []
    end

    # @return [Scope]
    # stub
    # TODO: deprecate? probably unused
    def scope
      where('1 = 2')
    end

    # @return [Array]
    def terms=(string)
      @query_string = string
      build_terms
      terms
    end

    # @return [Array]
    def terms
      if @terms.nil? || (@terms == [] && !@query_string.blank?)
        @terms = build_terms
      end
      @terms
    end

    def no_terms?
      terms.none?
    end

    # @return [Array]
    #   a reasonable (starting) interpretation of any query string
    # Ultimately we should replace this concept with full text indexing.
    def build_terms
      @terms = @query_string.blank? ? [] : [end_wildcard, start_and_end_wildcard]
    end

    # @return [String]
    def start_wildcard
      '%' + query_string
    end

    # @return [String]
    def end_wildcard
      query_string + '%'
    end

    # @return [String]
    def start_and_end_wildcard
      '%' + query_string + '%'
    end

    # @return [Array]
    def alphabetic_strings
      Utilities::Strings.alphabetic_strings(query_string) #alphanumeric allows searches by page number, year, etc.
    end

    # @return [Array]
    def alphanumeric_strings
      Utilities::Strings.alphanumeric_strings(query_string) #alphanumeric allows searches by page number, year, etc.
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

    # @return [String]
    #   if `foo, and 123 and stuff` then %foo%and%123%and%stuff%
    def wildcard_pieces
      a = '%' + query_string.gsub(/[^[[:word:]]]+/, '%') + '%' ### DD: if query_string is cyrilic or diacritics, it returns '%%%'
      a = 'NothingToMatch' if a.gsub('%','').gsub(' ', '').blank?
      a
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

    # generic multi-use bits
    #   table is defined in each query, it is the class of instances being returned

    # params attribute [Symbol]
    #   a facet for use when params include, `author`, and `exact_author` combinations
    #   See queries/source/filter.rb for example use
    def attribute_exact_facet(attribute = nil)
      a = attribute.to_sym
      return nil if send(a).blank?
      if send("exact_#{a}".to_sym)
        table[a].eq(send(a).strip)
      else
        table[a].matches('%' + send(a).strip.gsub(/\s+/, '%') + '%')
      end
    end

    # @return [Scope]
    def parent_child_join
      table.join(parent).on(table[:parent_id].eq(parent[:id])).join_sources # !! join_sources ftw
    end

    # Match at two levels, for example, 'wa te" will match "Washington Co., Texas"
    # @return [Arel::Nodes::Grouping]
    def parent_child_where
      a,b = query_string.split(/\s+/, 2)
      return table[:id].eq(-1) if a.nil? || b.nil?
      table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
    end

    # @return [Query, nil]
    #   used in or_clauses
    def with_id
      if integers.any?
        table[:id].eq_any(integers)
      else
        nil
      end
    end

    # @return [Query, nil]
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
      table[:name].eq(query_string) if !query_string.blank?
    end

    # @return [Arel::Nodes::TableAlias]
    def parent
      table.alias
    end

    # TODO: nil/or clause this
    # @return [Arel::Nodes::Equality]
    def with_project_id
      if project_id
        table[:project_id].eq(project_id)
      else
        nil
      end
    end

    # !!TODO: rename :cached_matches or similar (this is problematic !!)
    # @return [ActiveRecord::Relation, nil]
    #   cached matches full query string wildcarded
    def cached
      return nil if no_terms?
      (table[:cached].matches_any(terms)).or(match_ordered_wildcard_pieces_in_cached)
    end

    # @return [Arel::Nodes::Matches]
    def with_cached
      table[:cached].eq(query_string)
    end

    # @return [Arel::Nodes::Matches]
    def with_cached_like
      table[:cached].matches(start_and_end_wildcard)
    end

    # @return [Arel::Nodes::Matches]
    def match_ordered_wildcard_pieces_in_cached
      table[:cached].matches(wildcard_pieces)
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

    def levenshtein_distance(attribute, value)
      value = "'" + value.gsub(/'/, "''") + "'"
      a = ApplicationRecord.sanitize_sql(value)
      Arel::Nodes::NamedFunction.new("levenshtein", [table[attribute], Arel::Nodes::SqlLiteral.new(a) ] )
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
