module Queries

  # See
  #  http://www.slideshare.net/camerondutro/advanced-arel-when-activerecord-just-isnt-enough
  #  https://github.com/rails/arel
  #  http://robots.thoughtbot.com/using-arel-to-compose-sql-queries
  #  https://github.com/rails/arel/blob/master/lib/arel/predications.rb
  #  And this:
  #    http://blog.arkency.com/2013/12/rails4-preloading/
  #    User.includes(:addresses).where("addresses.country = ?", "Poland").references(:addresses)
  #

  # Lots of optimization possible, at minimum this is nice for nested OR
  class Otu::Autocomplete < Queries::Query

    def base_query
      ::Otu.select('otus.*')
    end

    # @return [Arel::Table]
    def taxon_name_table
      ::TaxonName.arel_table
    end

    # @return [Arel::Table]
    def table
      ::Otu.arel_table
    end

    # @return [Scope]
    def where_sql
      with_project_id.and(or_clauses).to_sql
    end

    def base_queries
      queries = [
        autocomplete_or_clauses,
        autocomplete_identifier_cached_exact,
        autocomplete_identifier_identifier_exact,
        autocomplete_identifier_cached_like,
      ]

      queries.compact!

      return [] if queries.nil?
      updated_queries = []

      queries.each_with_index do |q ,i|
        a = q.where(project_id: project_id) if project_id
        a ||= q 
        updated_queries[i] = a
      end
    end

    # @return [Array]
    #   TODO: optimize limits
    def autocomplete
      updated_queries = base_queries      
      result = []
      updated_queries.each do |q|
        result += q.to_a
        result.uniq!
        break if result.count > 39 
      end
      result[0..39]
    end

    # @return [Scope]
    def or_clauses
      clauses = [
        named,
        taxon_name_named,
        taxon_name_author_year_matches,
        with_id,
      ].compact

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end

    # @return [Scope]
    def autocomplete_or_clauses
      ::Otu.includes(:taxon_name).where(where_sql).references(:taxon_names).order(name: :asc).limit(50).order('taxon_names.cached ASC')
    end

    # @return [Arel::Nodes::Matches]
    def taxon_name_named
      taxon_name_table[:cached].matches_any(terms)
    end

    # @return [Arel::Nodes::Matches]
    def taxon_name_author_year_matches
      a = authorship
      return nil if a.nil?
      taxon_name_table[:cached_author_year].matches(a)
    end

    # @return [String]
    def authorship
      parser = ScientificNameParser.new
      a = parser.parse(query_string)
      b = a[:scientificName]
      return nil if b.nil? or b[:details].nil?

      b[:details].each do |detail|
        detail.each_value do |v|
          if v.kind_of?(Hash) && v[:authorship]
            return v[:authorship]
          end
        end
      end
      nil
    end

  end
end
