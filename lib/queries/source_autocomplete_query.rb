module Queries

  class SourceAutocompleteQuery < Queries::Query

    include Arel::Nodes

    def cached
      table[:cached].matches_any(strings)
    end

    def where_sql
      cached.or(with_id).to_sql
    end
    
    def year
      if !years.empty?
        table[:year].eq_any(years) 
      else
        table[:year].eq('%')
      end
    end

    def cached_full_match
      table[:cached].matches("%#{no_digits}%")
    end

    # First attemt
    def all 
      ( 
       [ Source.find_by_cached(query_string) ]  +
       Source.where(cached_full_match.and(year).to_sql).limit(5) +
       Source.where(with_id.to_sql).limit(5) +
       Source.where(cached.and(year).to_sql).limit(10) +
       Source.where(table[:cached].matches_any(terms)).limit(20)  
      ).flatten.compact.uniq
    end

    def table
      Source.arel_table
    end

  end
end
