module Queries
  class ContainerAutocompleteQuery < Queries::Query


    def where_sql
      with_project_id.or(with_identifier_like)
    end

    def result
      Container.includes(:identifiers).where(where_sql).references(:identifiers)
    end

    def table
      Container.arel_table
    end

  end
end
