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

    # @return [Boolean]
    #   &exact=<"true"|"false">
    #   if 'true' then only #name = query_string results are returned (no fuzzy matching)
    attr_accessor :exact

    def initialize(string, project_id: nil, valid: nil, nomenclature_group: [], type: [], parent_id: [], exact: false)
      @nomenclature_group = nomenclature_group
      @valid = valid == 'true' ? true : (valid == 'false' ? false : nil) 
      @type = type 
      @parent_id = parent_id 
      @exact = exact == 'true' ? true : (exact == 'false' ? false : nil) 
      super
    end

    def or_clauses
      clauses = []

      clauses.push exactly_named if exact

      clauses += [
        only_ids,
        cached,
        with_cached_author_year,
      ] unless exact

      clauses.compact!

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
      TaxonName.select('taxon_names.*, char_length(taxon_names.cached)').
        includes(:ancestor_hierarchies).
        where(where_sql).
        references(:taxon_name_hierarchies).
        limit(dynamic_limit).order("char_length(taxon_names.cached), taxon_names.cached").distinct.all
    end

    def autocomplete_top_name
      a = table[:name].eq(query_string)
      base_query.where(a.to_sql).order('cached ASC').limit(20)
    end

    def autocomplete_top_cached
      a = table[:cached].matches("%(#{query_string})")
      base_query.where(a.to_sql).limit(1)
    end

    def autocomplete_genus_species1(result)
      return nil if result.nil?
      a = table[:cached].matches(result)
      base_query.where(a.to_sql).order('type DESC, cached ASC').limit(8)
    end

    def autocomplete_genus_species2(result)
      return nil if result.nil?
      a = table[:cached].matches(result + '%')
      base_query.where(a.to_sql).order('type DESC, cached ASC').limit(8)
    end

    def autocomplete_cached_end_wildcard
      a = table[:cached].matches("#{query_string}%")
      base_query.where(a.to_sql).order('char_length(cached), cached ASC').limit(20)
    end

    def autocomplete_cached_wildcard_whitespace
      a = table[:cached].matches("#{query_string.gsub(' ', '%')}")
      base_query.where(a.to_sql).order('char_length(cached), cached ASC').limit(20)
    end

    def autocomplete_fragments
      f = fragments 
      if f.size == 2
        a = table[:cached].matches(f[0]).and(table[:cached_author_year].matches(f[1]))
        base_query.where(a.to_sql).order('char_length(cached), cached ASC').limit(20)
      else
        nil
      end
    end

    def autocomplete_name_author_year
      a = table[:cached_author_year].matches("#{query_string.gsub(/[,\s]/, '%')}")
      base_query.where(a.to_sql).order('cached ASC').limit(20)
    end

    def autocomplete
      z = genus_species
      
      queries = [
        autocomplete_top_name,
        autocomplete_top_cached,
        autocomplete_genus_species1(z),
        autocomplete_genus_species2(z),
        autocomplete_cached_end_wildcard,
        autocomplete_cached_wildcard_whitespace,
        autocomplete_fragments,
        autocomplete_name_author_year
      ]

      queries.compact!

      updated_queries = []
      queries.each_with_index do |q,i|  
        a = q.where(project_id: project_id) if project_id
        a = a.where(and_clauses.to_sql) if and_clauses
        updated_queries[i] = a
      end

      result = []
      updated_queries.each do |q|
        result += q.to_a
        result.uniq
        break if result.count > 19
      end

      result[0..19].uniq
    end

    def genus_species
      parser = ScientificNameParser.new
      h = parser.parse(query_string)
      n = h[:scientificName][:details]

      if n && n.first && n.first[:genus] && n.first[:species]
        a = n.first[:genus][:string]
        b = n.first[:species][:string]

        a + '%' + b 
      else
        nil
      end
    end

    def base_query
      TaxonName.select('taxon_names.*, char_length(taxon_names.cached)').
        includes(:ancestor_hierarchies)
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
