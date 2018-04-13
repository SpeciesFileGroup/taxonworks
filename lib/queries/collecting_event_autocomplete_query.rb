module Queries

  # Presently, search by:
  #   !! UPDATE THIS
  #    id
  #    cached (term, term[n], term[n]%)
  #    identifier#cached
  #    geographic_area#name (term, term%)
  #
  #
  class CollectingEventAutocompleteQuery

    # @param [Hash] args
    # @return [Ignored]
    def initialize(string)
      build_terms(string)
    end

    # @param [String] string
    # @return [Void]
    def terms=(string)
      build_terms(string)
    end

    # @param [String] string
    # @return [String]
    def build_terms(string)
      string = string.to_s
      @terms ||= [string, "%#{string}", "%#{string}%", "%#{string}%"] + string.split(/\s/).collect{|t| [t, "#{t}%"]}.flatten
    end

    # @return [Array]
    def terms
      @terms
    end

    # @return [String]
    def where_sql
      with_id.or(identified_by).or(with_verbatim_locality).or(with_cached).or(geographic_area_named).to_sql
    end

    # @return [Scope]
    def all
      CollectingEvent.includes(:geographic_area, :identifiers)
        .where(where_sql)
        .references(:geographic_areas, :identifiers)
        .limit(40)
    end

    # @return [Arel::Table]
    def geographic_area_table
      GeographicArea.arel_table
    end

    # @return [Arel::Table]
    def identifier_table
      Identifier.arel_table
    end

    # @return [Arel::Table]
    def table
      CollectingEvent.arel_table
    end

    # @return [Arel::Nodes::Equality]
    def with_id
      table[:id].eq(@terms.first.to_i)
    end

    # @return [Arel::Nodes::Matches]
    def with_cached
      table[:cached].matches_any(@terms)
    end

    # @return [Arel::Nodes::Equality]
    def with_verbatim_trip_code
      table[:verbatim_trip_code].eq_any(@terms)
    end

    # @return [Arel::Nodes::Equality]
    def with_verbatim_locality
      table[:verbatim_locality].eq_any(@terms)
    end

    # @return [Arel::Nodes::Matches]
    def identified_by
      identifier_table[:cached].matches_any(@terms)
    end

    # @return [Arel::Nodes::Matches]
    def geographic_area_named
      geographic_area_table[:name].matches_any(@terms)
    end

  end
end
