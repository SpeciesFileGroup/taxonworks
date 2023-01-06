# A module for composing (TaxonWorks referencing) Queries.
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
# TODO:
#  Define #all as a stub (Array or AR)
#   * recover class from module
#
#
module Queries

  class Query
    include Arel::Nodes

    include Queries::Concerns::Identifiers

    # @return [Array]
    #   an expanded search target arary, splitting query_string into a number of wild-carded values
    attr_accessor :terms

    # @return [String]
    attr_accessor :query_string

    # See subclasses.
    def initialize
    end

    def table
      referenced_klass.arel_table
    end

    def base_query
      referenced_klass.select( referenced_klass.name.tableize + '.*'  )
    end

    def referenced_klass
      ('::' + self.class.name.split('::').second).safe_constantize
    end

    def terms=(string)
      @query_string = string
      build_terms
      terms
    end

    def terms
      if @terms.blank? && @query_string.present?
        @terms = build_terms
      elsif @query_string.blank?
        @terms = []
      else
        @terms
      end
    end

    # @return [Array]
    #   a reasonable (starting) interpretation of any query string
    # Ultimately we should replace this concept with full text indexing.
    def build_terms
      @terms = @query_string.blank? ? [] : [end_wildcard, start_and_end_wildcard]
    end

    def no_terms?
      terms.blank?
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
      Utilities::Strings.alphabetic_strings(query_string)
    end

    # @return [Array]
    def alphanumeric_strings
      Utilities::Strings.alphanumeric_strings(query_string)
    end

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

    def levenshtein_distance(attribute, value)
      value = "'" + value.gsub(/'/, "''") + "'"
      a = ApplicationRecord.sanitize_sql(value)
      Arel::Nodes::NamedFunction.new("levenshtein", [table[attribute], Arel::Nodes::SqlLiteral.new(a) ] )
    end

  end
end
