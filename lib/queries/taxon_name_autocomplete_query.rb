module Queries

  class TaxonNameAutocompleteQuery < Queries::Query

    def where_sql
      named.or(with_cached).or(with_verbatim_author).or(with_year_of_publication).to_sql
    end

    def all 
      TaxonName.where(where_sql).limit(dynamic_limit) # .references(:taxon_names)
    end

    def table
      TaxonName.arel_table
    end

    def with_cached
      table[:cached].matches_any(terms)
    end

    def with_verbatim_author
      table[:verbatim_author].matches_any(terms)
    end

    def with_year_of_publication
      table[:year_of_publication].eq_any(terms)
    end

    def named
      table[:name].matches_any(terms)
    end
    
  end
end
