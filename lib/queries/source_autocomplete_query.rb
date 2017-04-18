module Queries

  class SourceAutocompleteQuery < Queries::Query

    include Arel::Nodes

    def cached_matches_fragments
      if strings.count < 6
        if years.empty?
          table[:cached].matches_any(strings)
        else
          table[:cached].matches_any(strings).and(table[:year].eq_any(years))
        end
      else
        nil
      end
    end

    def cached_matches
      table[:cached].matches_any(terms)
    end

    def where_sql
      or_clauses.to_sql
    end

    def or_clauses
      clauses = [
        with_id,
        cached_matches,
        cached_matches_fragments
      ].compact

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end 

    # !! needs major refactoring, thought
    # @return [Array]
    def all 
      Source.where(where_sql).uniq.limit(50).order(:cached)
    end

    def by_project_all
      ( 
       [ Source.joins(:project_sources).where(member_of_project_id.to_sql).find_by_cached(query_string) ]  +
         Source.joins(:project_sources).where(member_of_project_id.to_sql).where(cached_full_match.and(year).to_sql).limit(10) +
         Source.joins(:project_sources).where(member_of_project_id.to_sql).where(with_id.to_sql).limit(5) +
         Source.joins(:project_sources).where(member_of_project_id.to_sql).where(cached.and(year).to_sql).limit(10) +
         Source.joins(:project_sources).where(member_of_project_id.to_sql).where(cached.to_sql).limit(20)  
      ).flatten.compact.uniq
    end

    def table
      Source.arel_table
    end

    def project_sources_table
      ProjectSource.arel_table
    end

    def member_of_project_id
      project_sources_table[:project_id].eq(project_id)
    end

  end
end
