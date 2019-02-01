module Queries
  class ContainerAutocompleteQuery < Queries::Query

    # @return [String]
    def where_sql
      with_project_id.or(with_identifier_like)
    end

    # @return [Scope]
    def result
      ::Container.includes(:identifiers).where(where_sql).references(:identifiers)
    end

    # @return [Arel::Table]
    def table
      ::Container.arel_table
    end

  end
end
