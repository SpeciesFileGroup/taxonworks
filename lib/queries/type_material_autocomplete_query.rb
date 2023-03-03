module Queries

  class TypeMaterialAutocompleteQuery < Queries::Query

    # @return [String]
    def where_sql
      with_project_id.and(with_cached_taxon_name.or(with_cached_identifier)).to_sql
    end

    # @return [Scope]
    def all
      ::TypeMaterial.includes(:protonym, collection_object: [:identifiers] ).where(where_sql).references(:taxon_names).limit(dynamic_limit).all
    end

    # @return [Arel::Table]
    def taxon_name_table
      ::TaxonName.arel_table
    end

    # @return [Arel::Table]
    def identifier_table
      ::Identifier.arel_table
    end

    # source, material, prototonym
    # @return [Arel::Nodes::Matches]
    def with_cached_taxon_name
      taxon_name_table[:cached].matches_any(terms)
    end

    # @return [Arel::Nodes::Matches]
    def with_cached_identifier
      identifier_table[:cached].matches_any(terms)
    end

  end
end
