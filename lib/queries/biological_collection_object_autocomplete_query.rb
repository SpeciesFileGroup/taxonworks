module Queries
  class BiologicalCollectionObjectAutocompleteQuery
    include Arel::Nodes

    attr_accessor :terms

    def initialize(string)
      build_terms(string)
    end

    def terms=(string)
      build_terms(string)
    end

    def build_terms(string)
      string = string.to_s
      @terms = [string] + string.split(/\s/).collect{|t| [t, "#{t}%"]}.flatten 
    end

    def where_sql
      with_id.or(identified_by).or(otu_determined_as).or(taxon_name_determined_as).to_sql
    end

    def all 
      CollectionObject::BiologicalCollectionObject.includes(:identifiers, taxon_determinations: { otu:  :taxon_name }  ).where(where_sql).references(:taxon_names, :otus, :identifiers)
    end

    def taxon_name_table
      TaxonName.arel_table
    end

    def taxon_name_determination_table
      TaxonNameDetermination.arel_table
    end

    def identifier_table
      Identifier.arel_table
    end

    def otu_table
      Otu.arel_table
    end

    def table
      CollectionObject.arel_table
    end

    def with_id 
      table[:id].eq(@terms.first.to_i)
    end

    def identified_by
      identifier_table[:cached].eq_any(@terms) 
    end

    def otu_determined_as 
      otu_table[:name].matches_any(@terms)
    end

    def taxon_name_determined_as 
      taxon_name_table[:name].matches_any(@terms).or(taxon_name_table[:cached].matches_any(@terms) )
    end
  
  end
end
