module Queries

  class RepositoryAutocompleteQuery < Queries::Query

    def where_sql
      named.or(acronym).to_sql
    end

    def all 
      Repository.where(where_sql).order('name, char_length(name)').limit(40)
    end

    def table
      Repository.arel_table
    end

    def acronym
      table[:acronym].matches_any(terms)
    end
  end
end
