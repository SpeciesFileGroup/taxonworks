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

  class GeographicAreaAutocompleteQuery
    include Arel::Nodes

    attr_accessor :search_string
    attr_accessor :terms
    attr_accessor :limit

    def initialize(string)
      @search_string = string
      build_terms(string)
      @limit = 100 
    end

    def terms=(string)
      case string.length
      when 0..3
        @limit = 20
      else
        @limit = 40
      end

      build_terms(string)
    end

    def build_terms(string)
      @terms = string.split(/\s/).collect{|t| [t, "#{t}%", "#{t}%"]}.flatten # , "#{t}%", "
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
      named.or(with_id).to_sql
    end

    def all 
      ( [GeographicArea.where(name: @search_string).all] + GeographicArea.where(where_sql).includes(:geographic_area_type, :geographic_items).order('length(name)').limit(@limit).all).flatten.compact.uniq
    end

    def table
      GeographicArea.arel_table
    end

    def named
      table[:name].matches_any(@terms)
    end

    def with_id
      table[:id].eq_any(@terms)
    end

  end
end
