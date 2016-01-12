module Queries

  class TaxonNameAutocompleteQuery < Queries::Query

    def where_sql
      with_project_id.and(named.or(with_cached).or(with_verbatim_author).or(with_year_of_publication)).to_sql
    end

    def all 
     a = TaxonName.where(with_project_id.to_sql).where(['name = ?', query_string]).order(:name).all +
     b = TaxonName.joins(parent_child_join).where(with_project_id.to_sql).where(parent_child_where.to_sql).limit(3).order(:name).all       
     c = TaxonName.where(where_sql).limit(dynamic_limit).order(:cached).all
     a + b + c 
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
      if integers.any?
        table[:year_of_publication].eq_any(integers)
      else
        table[:id].eq(-1)
      end
    end

    # Note this overwrites the commonly used Geo parent/child! 
    def parent_child_where
      b,a = query_string.split(/\s+/, 2)
      return table[:id].eq('-1') if a.nil? || b.nil?
      table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
    end
   
  end
end
