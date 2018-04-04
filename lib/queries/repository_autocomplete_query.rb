module Queries

  class RepositoryAutocompleteQuery < Queries::Query

    # @return [String]
    def where_sql
      named.or(acronym).to_sql
    end

    # @return [Scope]
    def all
      Repository.where(where_sql).order('name, char_length(name)').limit(40)
    end

    # @return [Arel::Table]
    def table
      Repository.arel_table
    end

    # @return [Arel::Nodes::Matches]
    def acronym
      table[:acronym].matches_any(terms)
    end
  end
end
