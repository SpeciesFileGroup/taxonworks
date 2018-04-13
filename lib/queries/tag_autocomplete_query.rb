module Queries

  class TagAutocompleteQuery < Queries::Query

    # @return [String]
    def where_sql
      with_project_id.and(or_clauses).to_sql
    end

    # @return [Arel::Nodes::Grouping]
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

    # @return [Arel::Table]
    def keyword_table
      Keyword.arel_table
    end

    # @return [Arel::Table]
    def table
      Tag.arel_table
    end

    # @return [Arel::Nodes::Matches]
    def keyword_named
      keyword_table[:name].matches_any(terms)
    end

    # @return [Arel::Nodes::Matches]
    def keyword_definition_matches
      keyword_table[:definition].matches_any(terms)
    end

  end
end
