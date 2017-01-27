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
  class OtuAutocompleteQuery < Queries::Query
    include Arel::Nodes

    def where_sql
      with_project_id.and(or_clauses).to_sql
    end

    def or_clauses
      clauses = [
        named,
        taxon_name_named,
        taxon_name_author_year_matches 
      ].compact

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end 
    
    # @return [Scope]
    def all 
      # For references, this is equivalent: Otu.eager_load(:taxon_name).where(where_sql) 
      Otu.includes(:taxon_name).where(where_sql).references(:taxon_names).order(name: :asc).limit(50).order('taxon_names.cached ASC')
    end

    def taxon_name_table
      TaxonName.arel_table
    end

    def table
      Otu.arel_table
    end

    def taxon_name_named
      taxon_name_table[:name].matches_any(terms)
    end

    def taxon_name_author_year_matches
      a = authorship
      return nil if a.nil?
      taxon_name_table[:cached_author_year].matches(a)
    end

    def authorship
      parser = ScientificNameParser.new
      a = parser.parse(query_string)
      b = a[:scientificName]
      return nil if b.nil? or b[:details].nil?

      b[:details].each do |detail|
        detail.each do |k,v|
          if v[:authorship]
            return v[:authorship] 
          end
        end
      end
      nil
    end

  end
end
