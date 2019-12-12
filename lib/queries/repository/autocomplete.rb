module Queries

  class Repository::Autocomplete < Queries::Query

    # @return [String]
    def where_sql
      a = [
        named,
        acronym
      ].compact

      return a.first.or(a.second) if a.size == 2
      a 
    end

    # @return [Scope]
    def all
      ::Repository.where(where_sql).order('name, char_length(name)').limit(40)
    end

    # @return [Arel::Table]
    def table
      ::Repository.arel_table
    end

    # @return [Arel::Nodes::Matches]
    def acronym
      table[:acronym].matches_any(terms) unless !terms.any?
    end
  end
end
