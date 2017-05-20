module Queries

  class TaxonNameAutocompleteQuery < Queries::Query

    # [:higher, :family, :genus, :species]
    attr_accessor :nomenclature_group

    # only with id == cached_valid_taxon_name_id
    # true, false, nil = true || false
    attr_accessor :valid

    # type == [] 
    attr_accessor :type

    # parent_id in []
    attr_accessor :parent_id
    
    def initialize(string, project_id: nil, valid: nil, nomenclature_group: [], type: [], parent_id: [])
      @nomenclature_group = nomenclature_group
      @valid = valid 
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

    def valid_state
      return nil if @valid.nil?
      valid ? table[:id].eq(table[:cached_valid_taxon_name_id]) : table[:id].not(eq(table[:cached_valid_taxon_name_id]))
    end

    def is_type
      return nil if type.empty?
      table[:type].eq_any(type)
    end

    def with_parent_id 
      return nil
      return nil if parent_id.empty?
      TaxonName.with_ancestor(parent_id) # plural
    end

    def taxon_name_heirarchies_table
      TaxonNameHierarchies.arel_table 
    end 

    def parent_id
      taxon_name_heirarchies_table
    end

    joins(:descendant_hierarchies)
      .where(taxon_name_hierarchies: {descendant_id: taxon_name.id})
      .where('taxon_name_hierarchies.ancestor_id != ?', taxon_name.id) 
 

    def with_nomenclature_group
      table[:rank_class].matches_any(nomenclature_group)
    end

    def nomenclature_group
      @nomenclature_group.collect{|g| "::#{g}%"}
    end

    def and_clauses
      clauses = [
        valid_state,
        is_type,
        with_parent_id
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

    def all
      TaxonName.where(where_sql).limit(dynamic_limit).includes(:descendant_hierarchies).order(:cached).uniq.all
    # a = TaxonName.where(with_project_id.to_sql).where(['name = ?', query_string]).order(:name).all +
    #  b = TaxonName.joins(parent_child_join).where(with_project_id.to_sql).where(parent_child_where.to_sql).limit(3).order(:name).all       
    #c = TaxonName.where(where_sql).limit(dynamic_limit).order(:cached).all
    #(a + b + c).uniq
    end

    def table
      TaxonName.arel_table
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
