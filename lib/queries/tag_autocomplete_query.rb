module Queries

  class TagAutocompleteQuery < Queries::Query
    include Arel::Nodes

    def where_sql
      with_project_id.and(or_clauses).to_sql
    end

    def or_clauses
      clauses = [
        keyword_named,
        keyword_definition_matches, 
        with_id
      ].compact

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end 
    
    # @return [Scope]
    def all 
      Tag.includes(:keyword).where(where_sql).references(:keywords).merge(Keyword.order(:name)).limit(50)
    end

    def keyword_table
      Keyword.arel_table
    end

    def table
      Tag.arel_table
    end

    def keyword_named
      keyword_table[:name].matches_any(terms)
    end

    def keyword_definition_matches
      keyword_table[:definition].matches_any(terms)
    end

  end
end
