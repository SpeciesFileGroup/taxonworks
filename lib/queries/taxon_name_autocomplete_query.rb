module Queries


  class TaxonNameAutocompleteQuery < Queries::Query

    # @return [Array, nil]
    #   &nomenclature_group[]=<<Iczn|Icnb|Icn>::<Higher|Family|Genus|Species>>
    attr_accessor :nomenclature_group

    # @return [Boolean, nil]
    #  &valid=<"true"|"false"> 
    #     if 'true'  then id == cached_valid_taxon_name_id
    #     if 'false' then id != cached_valid_taxon_name
    #     if nil   then no check made, i.e. all names
    #  string is converted to Boolean here
    attr_accessor :valid

    # @return [Array]
    #   &type[]=<Protonym, Combination, Hybrid, etc.>&type[]=<other type> etc.
    attr_accessor :type

    # @return [Array]
    #   &parent_id[]=<int>&parent_id=<other_int> etc.
    attr_accessor :parent_id
    
    def initialize(string, project_id: nil, valid: nil, nomenclature_group: [], type: [], parent_id: [])
      @nomenclature_group = nomenclature_group
      @valid = valid == 'true' ? true : (valid == 'false' ? false : nil) 
      @type = type 
      @parent_id = parent_id 
      super
    end

    def or_clauses
      clauses = [
        only_ids,
        cached,
        with_cached_author_year,
      ].compact

      a = clauses.shift
      clauses.each do |b|
        a = a.or(b)
      end
      a
    end

    def and_clauses
      clauses = [
        valid_state,
        is_type,
        with_parent_id,
        with_nomenclature_group
      ].compact

      return nil if clauses.nil?
      
      a = clauses.shift
      clauses.each do |b|
        a = a.and(b)
      end
      a
    end

    def or_and
      a = or_clauses
      b = and_clauses

      if a && b
        a.and(b)
      else
        a
      end
    end
    
    def where_sql
      with_project_id.and(or_and).to_sql
    end

    # @return [Arel::Nodes::<>, nil]
    # and clause
    def valid_state
      return nil if @valid.nil?
      valid ? table[:id].eq(table[:cached_valid_taxon_name_id]) : table[:id].not_eq(table[:cached_valid_taxon_name_id])
    end

    # and clause
    def is_type
      return nil if type.empty?
      table[:type].eq_any(type)
    end

    # and clause, limit to ancestors or [ids]
    def with_parent_id 
      return nil if parent_id.empty?
      taxon_name_hierarchies_table[:ancestor_id].eq_any(parent_id)
    end

    # @return [Arel::Nodes::Grouping, nil]
    #   and clause
    def with_nomenclature_group
      return nil if nomenclature_group.empty?
      table[:rank_class].matches_any(nomenclature_group)
    end

    # and_clause
    def nomenclature_group
      @nomenclature_group.collect{|g| "%::#{g}%"}
    end

    def all
      TaxonName.includes(:ancestor_hierarchies).where(where_sql).references(:taxon_name_hierarchies).limit(dynamic_limit).order(:cached).uniq.all
    end

    def table
      TaxonName.arel_table
    end

    def taxon_name_hierarchies_table
      Arel::Table.new('taxon_name_hierarchies')
    end 

    def with_cached_author_year
      table[:cached_author_year].matches_any(terms)
    end

    # Note this overwrites the commonly used Geo parent/child! 
    # def parent_child_where
    #   b,a = query_string.split(/\s+/, 2)
    #   return table[:id].eq('-1') if a.nil? || b.nil?
    #   table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
    # end
   
  end
end
