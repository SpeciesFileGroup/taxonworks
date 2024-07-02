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

      # As determined by GlobalNames parser
      attr_accessor :authorship

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
        table[:type].in(type)
      end

      # and clause, limit to ancestors or [ids]
      # @return [Arel::Nodes::<>, nil]
      def with_parent_id
        return nil if parent_id.empty?
        taxon_name_hierarchies_table[:ancestor_id].in(parent_id)
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
      def autocomplete_exact_name
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
        a = table[:cached].matches("#{query_string.gsub('. ', ' ').gsub(/[\s\\]/, '%')}")
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

      #    def autocomplete_cached
      #      base_query.where(table[:cached].eq(query_term))
      #    end

      # ---- gin methods
      # Consider word_similarity()

      def autocomplete_cached
        ::TaxonName.where(project_id:).select(ApplicationRecord.sanitize_sql(['taxon_names.*, similarity(?, taxon_names.cached) AS sml', query_string]))
          .where('taxon_names.cached % ?', query_string) # `%` in where means nothing < 0.3 (internal PG similarity value)
          .where(ApplicationRecord.sanitize_sql_array(["similarity('%s', taxon_names.cached) > 0.6", query_string]))
          .order('sml DESC, taxon_names.cached')
      end

      def autocomplete_original_combination
        ::TaxonName.select(ApplicationRecord.sanitize_sql(['taxon_names.*, similarity(?, taxon_names.cached_original_combination) AS sml', query_string]))
          .where('taxon_names.cached_original_combination % ?', query_string)
          .where(ApplicationRecord.sanitize_sql_array(["similarity('%s', taxon_names.cached_original_combination) > 0.6", query_string]))
          .order('sml DESC, taxon_names.cached_original_combination')
      end

      def autocomplete_cached_author_year
        ::TaxonName.select(ApplicationRecord.sanitize_sql(['taxon_names.*, similarity(?, taxon_names.cached_author_year) AS sml', query_string]))
          .where('taxon_names.cached_author_year % ?', query_string)
          .where(ApplicationRecord.sanitize_sql(["similarity('%s', taxon_names.cached_author_year) > 0.6", query_string]))
          .order('sml DESC, taxon_names.cached_author_year')
      end

      # Weights.  Theory (using this loosely) is that this
      # will proportionally increase the importance in the list of the corresponding element.
      # The tradeoff is subtle, but seems to work at first try.
      CACHED_NAME_WEIGHT = 8.0
      CACHED_AUTHOR_YEAR_WEIGHT = 6.0
      CACHED_WEIGHT = 4.0
      CACHED_ORIGINAL_COMBINATION_WEIGHT = 2.0

      # Used in /otus/api/v1/autocomplete
      def autocomplete_combined_gin
        a = ::TaxonName.select(ApplicationRecord.sanitize_sql(
          ['taxon_names.*, similarity(?, name) AS sml_n, similarity(?, taxon_names.cached_author_year) AS sml_cay, similarity(?, cached) AS sml_c, similarity(?, taxon_names.cached_original_combination) AS sml_coc',
           query_string, authorship, query_string, query_string])
                              ).where('taxon_names.cached_author_year % ? OR taxon_names.cached_original_combination % ? OR cached % ?', query_string, query_string, query_string)

        s = 'WITH tns AS (' + a.to_sql + ') ' +
          ::TaxonName
          .select(Arel.sql("taxon_names.*, (( COALESCE(tns1.sml_n,0) * #{CACHED_NAME_WEIGHT} + \
                                                  COALESCE(tns1.sml_cay,0) * #{CACHED_AUTHOR_YEAR_WEIGHT} + \
                                                  COALESCE(tns1.sml_c,0) * #{CACHED_WEIGHT} + \
                                                  COALESCE(tns1.sml_coc,0) * #{CACHED_ORIGINAL_COMBINATION_WEIGHT} \
                                                )) sml_tn"))
          .joins('JOIN tns as tns1  on tns1.id = taxon_names.id')
          .to_sql

        ::TaxonName.select('taxon_names.*, sml_tn as sml_t').from('(' + s + ') as taxon_names').order('sml_tn DESC').distinct
      end

      # Used in New taxon name task, for example
      #  TODO: what is intent?
      def exact_autocomplete
        [
          autocomplete_exact_id,
          autocomplete_exact_cached,
          autocomplete_exact_cached_original_combination,
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,
          autocomplete_exact_name_and_year,

          autocomplete_cached_end_wildcard,
          autocomplete_cached_wildcard_whitespace,
          autocomplete_name_author_year_fragment,
          autocomplete_taxon_name_author_year_matches,
          autocomplete_wildcard_joined_strings,
          autocomplete_wildcard_author_year_joined_pieces,
          autocomplete_wildcard_cached_original_combination,
          autocomplete_exact_name, # not exact enough, want the whole thing?
          # autocomplete_top_cached, # not exact at all
        ]
      end

      # TODO: Refactor to OTU approach?
      def comprehensive_autocomplete
        z = genus_species
        queries = [
          autocomplete_exact_cached,
          autocomplete_exact_cached_original_combination,
          autocomplete_exact_name_and_year,
          autocomplete_exact_name,

          autocomplete_exact_id,
          autocomplete_identifier_cached_exact,
          autocomplete_identifier_identifier_exact,

          # All exact should be before these?
          #
          # There are left in, but the cutoff
          # is now 2x as high, i.e. more like wildcard matches we
          # were originally used to.
          autocomplete_cached, # sim
          autocomplete_original_combination, # sim
          autocomplete_cached_author_year, # sim

          # Specialized results
          autocomplete_genus_species1(z),    # not tested
          autocomplete_genus_species2(z),    # not tested
          autocomplete_top_cached_subgenus,  # not tested

          # autocomplete_top_cached, # Wildcard end
          # autocomplete_cached_end_wildcard,
          # autocomplete_cached_name_end_wildcard,
          # autocomplete_cached_wildcard_whitespace,
          # autocomplete_name_author_year_fragment,
          # autocomplete_taxon_name_author_year_matches,
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
        # exact, unified, comprehensive

        queries = (exact ? exact_autocomplete : comprehensive_autocomplete )
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
        p = Vendor::Biodiversity::Result.new
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

      # @return [String] (including empty)
      def authorship
        return @authorship if @authorship
        a = ::Biodiversity::Parser.parse(query_string)

        if a.dig(:parsed)
          @authorship = a.dig(:authorship, :normalized)
        else
          # Gnparser doesn't parse with names like `aus Jones`, do a quick and dirty check for things like `foo Jones`
          if a = query_string.match(/\A[a-z]+\s*\,?\s*(.*)\Z/)
            @authorship = a[1].gsub(/\\+\z/, '')
          else
            @authorship = ''
          end
        end

        @authorship
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
