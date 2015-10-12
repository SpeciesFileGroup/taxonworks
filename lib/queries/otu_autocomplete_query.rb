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
  class OtuAutocompleteQuery
    include Arel::Nodes

    attr_accessor :terms

    def initialize(string)
      build_terms(string)
    end

    def terms=(string)
      build_terms(string)
    end

    def build_terms(string)
      @terms = string.split(/\s/).collect{|t| [t, "#{t}%"]}.flatten # , "#{t}%", "%#{t}%"
    end

    # All sorts of messed up, badly miss-maps attributes
    # def query
    #   table.join(taxon_name_table, Arel::Nodes::OuterJoin)
    #     .on(table[:id].eq(taxon_name_table[:id]))
    #     .where(named.or(taxon_name_named))
    #     .take(40)
    #     .project(table['name'], taxon_name_table['name'])
    # end

    def where_sql
      named.or(taxon_name_named).to_sql
    end

    def all 
      # For references, this is equivalent: Otu.eager_load(:taxon_name).where(where_sql) 
      Otu.includes(:taxon_name).where(where_sql).references(:taxon_names).order(name: :asc).order('taxon_names.cached ASC')
    end

    def taxon_name_table
      TaxonName.arel_table
    end

    def table
      Otu.arel_table
    end

    def named
      table[:name].matches_any(@terms)
    end

    def taxon_name_named
      taxon_name_table[:name].matches_any(@terms)
    end
  end
end
