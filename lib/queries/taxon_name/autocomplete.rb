# TaxonNameAutocompleteQuery
module Queries
  module TaxonName
    class Autocomplete < Query::Autocomplete

      # @return [Array]
      #   &nomenclature_group[]=<<Iczn|Icnp|Icn>::<Higher|Family|Genus|Species>>
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
      #   &parent_id[]=<int>&parent_id[]=<other_int> etc.
      attr_accessor :parent_id

      # TODO: this should move to 'mode'

      # @return [Boolean]
      #   &exact=<"true"|"false">
      #   if 'true' then only #name = query_string results are returned (no fuzzy matching)
      attr_accessor :exact

      # @return [Boolean]
      #   &no_leaves=<"true"|"false">
      #     if 'true' then only names with descendents will be returned
      attr_accessor :no_leaves

      # @param [Hash] args
      def initialize(string, **params)
        @nomenclature_group = params[:nomenclature_group]
        @valid = boolean_param(params, :valid)
        @type = params[:type]
        @parent_id = params[:parent_id]
        @no_leaves = boolean_param(params, :no_leaves)

        # TODO: move to mode
        @exact = boolean_param(params, :exact)
        super
      end

      def nomenclature_group
        [@nomenclature_group].flatten.compact.uniq.collect{|g| "%::#{g}%"}
      end

      def type
        [@type].flatten.compact.uniq
      end

      def parent_id
        [@parent_id].flatten.compact.uniq
      end

      # @return [Arel:Nodes, nil]
      def and_clauses
        clauses = [
          valid_state,
          is_type,
          with_parent_id,
          with_nomenclature_group,
        ].compact

        return nil if clauses.nil?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Nodes::<>, nil]
      # and clause
      def valid_state
        return nil if @valid.nil?
        valid ? table[:id].eq(table[:cached_valid_taxon_name_id]) : table[:id].not_eq(table[:cached_valid_taxon_name_id])
      end

      # and clause
      # @return [Arel::Nodes::<>, nil]
      def is_type
        return nil if type.empty?
        table[:type].eq_any(type)
      end

      # and clause, limit to ancestors or [ids]
      # @return [Arel::Nodes::<>, nil]
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

      # @return [Scope]
      def autocomplete_exact_cached
        a = table[:cached].eq(query_string)
        base_query.where(a.to_sql).order('cached_author_year ASC').limit(20)
      end

      # @return [Scope]
      def autocomplete_exact_cached_original_combination
        a = table[:cached_original_combination].eq(query_string)
        base_query.where(a.to_sql).order('cached_author_year ASC').limit(20)
      end

      # @return [Scope]
      def autocomplete_wildcard_cached_original_combination
        a = table[:cached_original_combination].matches(wildcard_pieces)
        base_query.where(a.to_sql).order('cached_author_year ASC').limit(20)
      end

      # @return [Scope]
      def autocomplete_exact_name_and_year
        a = alphabetic_strings.select { |b| !(b =~ /\d/) }
        b = years
        if a.size == 1 && !b.empty?
          a = table[:name].eq(a.first).and(table[:cached_author_year].matches_any(wildcard_wrapped_years))
          base_query.where(a.to_sql).limit(10)
        else
          nil
        end
      end

      # @return [Scope]
      def autocomplete_top_name
        a = table[:name].eq(query_string)
        base_query.where(a.to_sql).order('cached_author_year ASC').limit(20)
      end

      # @return [Scope]
      def autocomplete_top_cached
        s = query_string
        a = table[:cached].matches("#{s}%")
        base_query.where(a.to_sql).limit(1)
      end

      # @return [Scope]
      def autocomplete_cached_end_wildcard
        s = query_string.delete('\\')
        a = table[:cached].matches("#{s}%")
        base_query.where(a.to_sql).limit(20)
      end

      # @return [Scope]
      def autocomplete_top_cached_subgenus
        a = table[:cached].matches("%(#{query_string})")
        base_query.where(a.to_sql).limit(1)
      end

      # @param [String] result
      # @return [Scope]
      def autocomplete_genus_species1(result)
        return nil if result.nil?
        a = table[:cached].matches(result)
        base_query.where(a.to_sql).order('type DESC, cached ASC').limit(8)
      end

      # @param [String] result
      # @return [Scope]
      def autocomplete_genus_species2(result)
        return nil if result.nil?
        a = table[:cached].matches(result + '%')
        base_query.where(a.to_sql).order('type DESC, cached ASC').limit(8)
      end

      # @return [Scope]
      def autocomplete_cached_name_end_wildcard
        a = table[:name].matches("#{query_string}%")
        base_query.where(a.to_sql).limit(20)
      end

      # @return [Scope]
      def autocomplete_cached_wildcard_whitespace
        a = table[:cached].matches("#{query_string.gsub('. ', ' ').gsub(' ', '%')}")
        base_query.where(a.to_sql).limit(20)
      end

      # @return [Scope, nil]
      def autocomplete_name_author_year_fragment
        f = fragments
        if f.size == 2
          a = table[:name].matches(f[0]).and(table[:cached_author_year].matches(f[1]))
          base_query.where(a.to_sql).limit(20)
        else
          nil
        end
      end

      # @return [Scope, nil]
      def autocomplete_wildcard_author_year_joined_pieces
        return nil if pieces.empty?
        a = table[:cached_author_year].matches("%#{pieces.join('%')}%")
        base_query.where(a.to_sql).order('cached ASC').limit(20)
      end

      # @return [Scope, nil]
      def autocomplete_wildcard_joined_strings
        return nil if alphabetic_strings.empty?
        a = table[:cached].matches("%#{alphabetic_strings.join('%')}%")
        base_query.where(a.to_sql).limit(10)
      end

      # @return [Arel::Nodes::Matches]
      def autocomplete_taxon_name_author_year_matches
        a = authorship
        return nil if a.nil?
        base_query.where(table[:cached_author_year].matches(a).to_sql).limit(10)
      end

      # ---- gin methods

      def autocomplete_cached
        ::TaxonName.where(project_id:).select("taxon_names.*, similarity('#{query_string}\', cached) AS sml")
        .where('cached % ?', query_string) # `%` in where means nothing < 0.3 (internal PG similarity value)
        .order('sml DESC, cached')
      end

      def autocomplete_original_combination
        ::TaxonName.select("taxon_names.*, similarity('#{query_string}\', cached_original_combination) AS sml")
        .where('cached_original_combination % ?', query_string)
        .order('sml DESC, cached_original_combination')
      end

      def autocomplete_cached_author_year
        ::TaxonName.select("taxon_names.*, similarity('#{query_string}\', cached_author_year) AS sml")
        .where('cached_author_year % ?', query_string)
        .order('sml DESC, cached_author_year')
      end

      # Used in /otus/api/v1/autocomplete
      def autocomplete_combined_gin
        a = ::TaxonName.select("taxon_names.*, similarity('#{query_string}\', cached_author_year) AS sml_cay, similarity('#{query_string}\', cached) AS sml_c, similarity('#{query_string}\', cached_original_combination) AS sml_coc")
        .where('cached_author_year % ? OR cached_original_combination % ? OR cached % ?', query_string, query_string, query_string)

        s = 'WITH tns AS (' + a.to_sql + ') ' +
            ::TaxonName
              .select(Arel.sql('taxon_names.*, ( (COALESCE(tns1.sml_cay,0) + COALESCE(tns1.sml_c,0) + COALESCE(tns1.sml_coc,0) ) / 3) sml_tn')) # max 3.0
              .joins('JOIN tns as tns1  on tns1.id = taxon_names.id')
              .to_sql

        ::TaxonName.select('taxon_names.*, sml_tn as sml_t').from('(' + s + ') as taxon_names').order('sml_tn DESC').distinct
      end

      # Used in New taxon name task, for example
      def exact_autocomplete
        [
          autocomplete_exact_id,
          autocomplete_exact_cached,
          autocomplete_exact_cached_original_combination,
          autocomplete_exact_name_and_year,
          autocomplete_top_name,
          autocomplete_top_cached,
          autocomplete_cached_end_wildcard
        ]
      end

      # TODO: deprecate, it unused as of the gin refactor.
      def comprehensive_autocomplete
        z = genus_species
        queries = [
           autocomplete_cached,
           autocomplete_original_combination,
           autocomplete_cached_author_year,
           autocomplete_exact_id,
           autocomplete_exact_cached,
           autocomplete_exact_cached_original_combination,
           autocomplete_identifier_cached_exact,
           autocomplete_exact_name_and_year,
           autocomplete_identifier_identifier_exact,
           autocomplete_top_name,
           autocomplete_top_cached,
           autocomplete_top_cached_subgenus,  # not tested
           autocomplete_genus_species1(z),    # not tested
           autocomplete_genus_species2(z),    # not tested
           autocomplete_cached_end_wildcard,
           # autocomplete_identifier_cached_like, # this query take much longer to complete than any other
           autocomplete_cached_name_end_wildcard,
           autocomplete_cached_wildcard_whitespace,
           autocomplete_name_author_year_fragment,
           autocomplete_taxon_name_author_year_matches,
           autocomplete_cached_author_year,
           autocomplete_wildcard_joined_strings,
           autocomplete_wildcard_author_year_joined_pieces,
           autocomplete_wildcard_cached_original_combination
        ]
      end

      def unified_autocomplete
        [
           autocomplete_exact_id,
           autocomplete_combined_gin,
           autocomplete_identifier_cached_exact,
        ]
      end

      # @return [Array]
      def autocomplete
        # TODO: switch to mode or individualize methods and feed to this
        queries = (exact ? exact_autocomplete : unified_autocomplete )
        queries.compact!

        result = []

        queries.each_with_index do |q,i|
          a = q
          a = q.where(project_id:) if project_id.present?

          a = a.where(and_clauses.to_sql) if and_clauses

          if !parent_id.empty?
            a = a.descendants_of(::TaxonName.where(id: parent_id))
          end

          a = a.not_leaves if no_leaves

          result += a.limit(20).to_a
          break if result.count > 19
        end

        result.uniq!
        # result[0..19]
        result
      end

      # @return [String, nil]
      #   parse and only return what is assumed to be genus/species, with a wildcard in front
      def genus_species
        p = TaxonWorks::Vendor::Biodiversity::Result.new
        p.name = query_string
        r = p.parse

        a = p.genus
        b = p.species

        if a && b
          a + '%' + b
        else
          nil
        end
      end

      # @return [Scope]
      # TODO: this should deprecate for gin based approaches.
      def base_query
        ::TaxonName.select('taxon_names.*, char_length(taxon_names.cached)')
          .includes(:ancestor_hierarchies)
          .order(Arel.sql('char_length(taxon_names.cached), taxon_names.cached ASC'))
      end

      # @return [Arel::Table]
      def taxon_name_hierarchies_table
        Arel::Table.new('taxon_name_hierarchies')
      end

      # @return [Arel::Nodes::Matches]
      def with_cached_author_year
        table[:cached_author_year].matches_any(terms)
      end

      # @return [String]
      def authorship
        ::Biodiversity::Parser.parse(query_string).dig(:authorship, :normalized)
      end

      # Note this overwrites the commonly used Geo parent/child!
      # def parent_child_where
      #   b,a = query_string.split(/\s+/, 2)
      #   return table[:id].eq('-1') if a.nil? || b.nil?
      #   table[:name].matches("#{a}%").and(parent[:name].matches("#{b}%"))
      # end

    end
  end
end
