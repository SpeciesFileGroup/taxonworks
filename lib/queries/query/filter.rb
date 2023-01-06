module Queries
  class Query::Filter < Queries::Query

    # include Queries::Concerns::Identifiers

    # @return [Array]
    attr_accessor :project_id

    def initialize(params)
      @project_id = params[:project_id] || Current.project_id # TODO: revisit
    end

    def project_id
      [@project_id].flatten.compact
    end

    # generic multi-use bits
    #   table is defined in each query, it is the class of instances being returned

    # params attribute [Symbol]
    #   a facet for use when params include `author`, and `exact_author` pattern combinations
    #   See queries/source/filter.rb for example use
    #   See /spec/lib/queries/source/filter_spec.rb
    #  !! Whitespace (e.g. tabs, newlines) is ignored when exact is used !!!
    def attribute_exact_facet(attribute = nil)
      a = attribute.to_sym
      return nil if send(a).blank?
      if send("exact_#{a}".to_sym)

        v = send(a)
        v.gsub!(/\s+/, ' ')
        v = ::Regexp.escape(v)
        v.gsub!(/\\\s+/, '\s*') # spaces are escaped, but we need to expand them in case we dont' get them caught
        v = '^\s*' + v + '\s*$'

        # !! May need to add table name here preceeding a.
        Arel::Nodes::SqlLiteral.new( "#{a} ~ '#{v}'" )
      else
        table[a].matches('%' + send(a).strip.gsub(/\s+/, '%') + '%')
      end
    end

    # 
    # TODO: Refactor below (largely update Source::Filter) to move these to Autcomplete
    #       and eliminate them from Filter subclass use.
    #

    # @return [Arel::Nodes::Matches]
    def match_ordered_wildcard_pieces_in_cached
      table[:cached].matches(wildcard_pieces)
    end

    # !!TODO: rename :cached_matches or similar (this is problematic !!)
    # @return [ActiveRecord::Relation, nil]
    #   cached matches full query string wildcarded
    def cached
      return nil if no_terms?
      (table[:cached].matches_any(terms)).or(match_ordered_wildcard_pieces_in_cached)
    end

    # @return [String]
    #   if `foo, and 123 and stuff` then %foo%and%123%and%stuff%
    def wildcard_pieces
      a = '%' + query_string.gsub(/[^[[:word:]]]+/, '%') + '%' ### DD: if query_string is cyrilic or diacritics, it returns '%%%'
      a = 'NothingToMatch' if a.gsub('%','').gsub(' ', '').blank?
      a
    end

    # @return [Arel::Nodes::TableAlias]
    # def parent
    #   table.alias
    # end
  end
end
