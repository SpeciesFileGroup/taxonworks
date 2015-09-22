module Queries


  class RepositoryAutocompleteQuery
    include Arel::Nodes

    attr_accessor :terms

    def initialize(string)
      build_terms(string)
    end

    def terms=(string)
      build_terms(string)
    end

    def build_terms(string)
      @terms = string.split(/\s/).collect{|t| [t, "#{t}%", "#{t}%"] }.flatten 
    end

    def where_sql
      named.or(acronym).to_sql
    end

    def all 
      Repository.where(where_sql)
    end

    def taxon_name_table
      Repository.arel_table
    end

    def table
      Repository.arel_table
    end

    def named
      table[:name].matches_any(@terms)
    end

    def acronym
      table[:acronym].matches_any(@terms)
    end
  end
end
