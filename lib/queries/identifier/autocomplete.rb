module Queries
  class Identifier::Autocomplete < Queries::Query


    def autocomplete
      queries = [
        autocomplete_exact_identifier,
        autocomplete_exact_cached,
        autocomplete_matching_cached,
        autocomplete_matching_cached_anywhere
     ]

      queries.compact!

      updated_queries = []
      queries.each_with_index do |q ,i|
        a = q.where(with_project_id.to_sql) if project_id 
        a ||= q
        updated_queries[i] = a
      end

      result = []
      updated_queries.each do |q|
        result += q.to_a
        result.uniq!
        break if result.count > 29
      end
      result[0..29]
    end

    def base_query
      ::Identifier.select('identifiers.*')
    end


    def autocomplete_exact_identifier
      base_query.where(with_identifier.to_sql).limit(15)
    end

    def autocomplete_exact_cached
      base_query.where(with_cached.to_sql).limit(2)
    end

    def autocomplete_matching_cached 
      base_query.where(with_identifier_wildcard_end).order('LENGTH(cached)').limit(20)
    end

    def autocomplete_matching_cached_anywhere 
      base_query.where(with_identifier_wildcard_anywhere).order('LENGTH(cached)').limit(20)
    end


    # @return [Arel::Table]
    def table
      ::Identifier.arel_table
    end

  end
end
