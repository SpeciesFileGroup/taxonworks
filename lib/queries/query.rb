# A module for composing (TaxonWorks referencing) queries.
#
# For insights on how these evolved see:
#  http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
#  https://github.com/rails/arel
#  http://robots.thoughtbot.com/using-arel-to-compose-sql-queries
#  https://github.com/rails/arel/blob/master/lib/arel/predications.rb
#
#  And this:
#    http://blog.arkency.com/2013/12/rails4-preloading/
#    User.includes(:addresses).where("addresses.country = ?", "Poland").references(:addresses)
#
module Queries

  class Query
    include Arel::Nodes

    include Queries::Concerns::Identifiers

    # !! TODO: search for collisions!
    # @return [Array]
    #   an expanded search target arary, splitting query_string into a number of wild-carded values
    attr_accessor :terms

    # @return [String]
    attr_accessor :query_string

#   # See subclasses.
#   def initialize
#   end

    # @return ApplicationRecord subclass
    #    e.g. Otu, TaxonName, the class this filter acts on
    def self.referenced_klass
      ('::' + name.split('::').second).safe_constantize
    end

    def self.base_name
      referenced_klass.name.tableize.singularize
    end

    # TODO: Deprecated
    # @params params ActionController::Parameters
    # @return ActionController::Parameters
    def self.permit(params)
      deep_permit(base_name.to_sym, params)
    end

    def table
      referenced_klass.arel_table
    end

    def base_query
      referenced_klass.select( referenced_klass.name.tableize + '.*'  )
    end

 #  def self.base_name
 #    referenced_klass.name.tableize.singularize
 #  end

    def referenced_klass
       self.class.referenced_klass
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


    def levenshtein_distance(attribute, value)
      value = "'" + value.gsub(/'/, "''") + "'"
      a = ApplicationRecord.sanitize_sql(value)
      Arel::Nodes::NamedFunction.new("levenshtein", [table[attribute], Arel::Nodes::SqlLiteral.new(a) ] )
    end

    #
    # TODO: Refactor below (largely remove reference from Source::Filter) to move these to Queries::Query::Autocomplete
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

  end
end
