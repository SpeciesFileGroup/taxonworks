module Queries
  class SourceFilterQuery < Queries::Query

    include Arel::Nodes

    # @return [ActiveRecord::Relation]
    def or_clauses
      clauses = [
        only_ids,               # only intgers provided
        cached,                 # should hit titles when provided alone, unfragmented string matches
        fragment_year_matches   # keyword style ANDs years
      ].compact

      
      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end

    # @return [String]
    def where_sql
      or_clauses.to_sql
    end

    # @return [ActiveRecord::Relation, nil]
    #    if user provides 5 or fewer strings and any number of years look for any string && year
    def fragment_year_matches
      if fragments.any?
        s = table[:cached].matches_any(fragments)
        s = s.and(table[:year].eq_any(years)) if !years.empty? 
        s
      else
        nil
      end 
    end

    # @return [ActiveRecord::Relation]
    def all 
      Source.where(where_sql).limit(500).uniq.order(:cached)
    end

    # @return [ActiveRecord::Relation]
    def by_project_all
      Source.where(where_sql).limit(500).uniq.order(:cached).joins(:project_sources).where(member_of_project_id.to_sql)
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
