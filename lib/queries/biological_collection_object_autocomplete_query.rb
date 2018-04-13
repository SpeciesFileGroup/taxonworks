module Queries
  class BiologicalCollectionObjectAutocompleteQuery < Queries::Query

    # @return [Array]
    def or_clauses
      combine_or_clauses(
        [
          with_id,
          with_identifier,
          with_identifier_like,
          otu_determined_as,
          taxon_name_determined_as
        ]
      )
    end

    # @return [String]
    def where_sql
      a = or_clauses
      a = a.and(with_project_id) if project_id
      a.to_sql
    end

    # @return [Scope]
    def all
      ::CollectionObject.
        includes(:identifiers, taxon_determinations: [ otu: [:taxon_name], determiners: [] ] ).
        where(where_sql).
        references(:taxon_names, :otus, :identifiers)
    end

    # @return [Array]
    #    results for autocomplete
    def autocomplete
      queries = []
      queries.push CollectionObject.includes(:identifiers, taxon_determinations: [otu: :taxon_name]).joins(:identifiers).where(with_identifier.to_sql).references(:identifiers).limit(2) if with_identifier
      queries.push CollectionObject.includes(:identifiers, taxon_determinations: [otu: :taxon_name]).joins(:identifiers).where(with_identifier_like.to_sql).references(:identifiers).order('identifiers.cached ASC').limit(10) if with_identifier_like
      queries.push CollectionObject.includes(:identifiers, taxon_determinations: [otu: :taxon_name]).where(with_id.to_sql).limit(1) if with_id
      queries.push CollectionObject.includes(:identifiers, taxon_determinations: [otu: :taxon_name]).joins(taxon_determinations: [:otu]).where(otu_determined_as.to_sql).references(:taxon_determinations, :otus).order('otus.name ASC').limit(10) if otu_determined_as
      queries.push CollectionObject.includes(:identifiers, taxon_determinations: [otu: :taxon_name]).joins(taxon_determinations: [otu: :taxon_name]).where(taxon_name_determined_as.to_sql).references(:taxon_determinations, :otus, :taxon_names).order('taxon_names.cached ASC').limit(10) if taxon_name_determined_as

      if project_id
        queries.each_with_index do |q,i|
          queries[i] = q.where(project_id: project_id)
        end
      end

      result = []
      queries.each do |q|
        result += q.to_a
        result.uniq!
        break if result.count > 19
      end

      result[0..19]
    end

    # @return [Arel::Table]
    def taxon_name_table
      ::TaxonName.arel_table
    end

    # @return [Arel::Table]
    def otu_table
      ::Otu.arel_table
    end

    # @return [Arel::Table]
    def table
      ::CollectionObject.arel_table
    end

    # @return [Arel::Nodes::Grouping]
    def otu_determined_as
      otu_table[:name].matches_any(terms)
    end

    # @return [Arel::Nodes::Grouping]
    def taxon_name_determined_as
      taxon_name_table[:name].matches_any(terms).or(taxon_name_table[:cached].matches_any(terms) )
    end

  end
end
