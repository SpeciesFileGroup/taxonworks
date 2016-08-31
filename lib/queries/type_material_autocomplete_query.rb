module Queries

  class TypeMaterialAutocompleteQuery < Queries::Query

    def where_sql
      with_project_id.and(with_cached_taxon_name.or(with_cached_identifier)).to_sql
    end

    def all
      TypeMaterial.includes(:protonym, material: [:identifiers] ).where(where_sql).references(:taxon_names).limit(dynamic_limit).all 
    end

    def table
      TypeMaterial.arel_table
    end

    def taxon_name_table
      TaxonName.arel_table
    end

    def identifier_table
      Identifier.arel_table
    end

    # source, material, prototonym
    def with_cached_taxon_name
      taxon_name_table[:cached].matches_any(terms)
    end

    def with_cached_identifier
      identifier_table[:cached].matches_any(terms)
    end

  end
end
