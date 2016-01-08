module Queries

  class TaxonNameAutocompleteQuery < Queries::Query

    def where_sql
      with_project_id.and(named.or(with_cached).or(with_verbatim_author).or(with_year_of_publication)).to_sql
    end

    def all 
      (
     #   TaxonName.where(name: query_string).all +  
        TaxonName.joins(parent_child_join).where(parent_child_where.to_sql).limit(5).all # +
     #   TaxonName.where(where_sql).limit(dynamic_limit) 
      ).flatten.compact.uniq
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

    # Note this overwrites the commonly used Geo parent/child! 
    def parent_child_where
      b,a = query_string.split(" ", 2)
      table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
    end
   
  end
end
