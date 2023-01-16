module Queries
  module TaxonName

    # Changed:
    # * added year_start, :year_end, :name_exact, :author_exact
    # * removed :exact

    # https://api.taxonworks.org/#/taxon_names
    class Filter < Query::Filter

      include Queries::Helpers

      include Queries::Concerns::Notes
      include Queries::Concerns::Tags
      include Queries::Concerns::DataAttributes

      # @params params ActionController::Parameters
      # @return ActionController::Parameters
      def self.base_params(params)
        params.permit(
          :ancestors,
          :author,
          :author_exact,
          :authors,
          :descendants,
          :descendants_max_depth,
          :etymology,
          :leaves,
          :name,
          :name_exact,
          :nomenclature_code,
          :nomenclature_group, # !! different than autocomplete
          :not_specified,
          :otu_id,
          :otus,
          :page,
          :per,
          :rank,
          :taxon_name_author_ids_or,
          :taxon_name_type,
          :type_metadata,
          :validify,
          :validity,
          :year,
          :year_end,
          :year_start,
          name: [],
          otu_id: [],
          combination_taxon_name_id: [],
          parent_id: [],
          rank: [],
          taxon_name_author_ids: [],
          taxon_name_classification: [],
          taxon_name_id: [],
          taxon_name_relationship: [
            :subject_taxon_name_id,
            :object_taxon_name_id,
            :type
          ],
          taxon_name_relationship_type: [],
          type: [],
          user_id: []
        )
      end

      # @param name [String, Array]
      # @return [Array]
      #  Matches against cached.  See also name_exact.
      attr_accessor :name

      # @return Boolean
      attr_accessor :name_exact

      # @param author [String]
      #   Use "&" for "and". Matches against cached_author_year. See also author_exact.
      attr_accessor :author

      # @return Boolean
      attr_accessor :author_exact

      # @param year [String]
      #   "yyyy"
      # Matches against cached_author_year.
      attr_accessor :year

      # @param year_start [String]
      #   "yyyy"
      # Matches against cached_nomenclature_date
      attr_accessor :year_start

      # @param year_start [String]
      #   "yyyy"
      # Matches against cached_nomenclature_date
      attr_accessor :year_end

      # @params validity [ Boolean]
      # ['true' or 'false'] on initialize
      #   true if only valid, false if only invalid, nil if both
      attr_accessor :validity

      # @params validity ['true', True, nil]
      # @return Boolean
      #    if true then for each name in the result its valid
      # name is returned
      # !! This param is not like the others. !! 
      attr_accessor :validify

      # @params taxon_name_id [Array]
      #   An array of taxon_name_id.
      # @return
      #   Return the taxon name(s) with this/these ids
      attr_accessor :taxon_name_id

      # @params parent_id[] [Array]
      #   An array of taxon_name_id.
      # @return
      #   Return the taxon names with this/these parent_ids
      attr_accessor :parent_id

      # @param descendants_max_depth [Integer]
      # A positive integer indicating how many levels deep of descendants to retrieve.
      #   Ignored when descentants is false/unspecified
      attr_accessor :descendants_max_depth

      # @param ancestors [Boolean, 'true', 'false', nil]
      # @return Boolean
      #   Ignored when taxon_name_id[].empty?  Works as AND clause with descendants :(
      attr_accessor :ancestors

      # @param descendants [Boolean, 'true', 'false', nil]
      # @return [Boolean]
      #   Ignored when taxon_name_id[].empty? Return descendants of parents as well.
      attr_accessor :descendants

      # @param taxon_name_relationship [Array]
      #  [ { 'type' => 'TaxonNameRelationship::<>', 'subject|object_taxon_name_id' => '123' } ... {} ]
      # Each entry must have a 'type'
      # Each entry must have one (and only one) of 'subject_taxon_name_id' or 'object_taxon_name_id'
      #
      # Return all taxon names in a relationship of a given type and in relation to a another name. For example, return all synonyms of Aus bus.
      attr_accessor :taxon_name_relationship

      # @param taxon_name_relationship [Array]
      #   All names involved in any of these relationship
      attr_accessor :taxon_name_relationship_type

      # @param taxon_name_classification [Array]
      #   Class names of TaxonNameClassification, as strings.
      attr_accessor :taxon_name_classification

      # @param otu_id [Array, nil]
      # @return [Array, nil]
      #   one or more OTU ids
      attr_accessor :otu_id

      # @param otus [Boolean, nil]
      # ['true' or 'false'] on initialize
      #   whether the name has an Otu
      attr_accessor :otus

      # @param etymology [Boolean, nil]
      # ['true' or 'false'] on initialize
      #   whether the name has etymology
      attr_accessor :etymology

      # @param authors [Boolean, nil]
      # ['true' or 'false'] on initialize
      #   whether the name has an author string, from any source, provided
      attr_accessor :authors

      # @params type_material [Boolean, nil]
      # ['true' or 'false'] on initialize
      #   whether the name has TypeMaterial
      attr_accessor :type_metadata

      # @params not_specified [Boolean, nil]
      #   whether the name has 'NOT SPECIFIED' in one of the cache values
      #   `true` - text is present
      #   `false` - text is absent
      #   nil - either present or absent
      attr_accessor :not_specified

      # @return [Array, nil]
      # &nomenclature_group=< Higher|Family|Genus|Species  >
      #  string matches `nomenclature_class`
      attr_accessor :nomenclature_group

      # @return [Array, nil]
      #   &nomenclature_code=Iczn|Icnp|Icn|Icvcn
      attr_accessor :nomenclature_code

      # TODO: inverse is duplicated in autocomplete
      # @return [Boolean, nil]
      #   &leaves=<"true"|"false">
      #   if 'true' then return only names without descendents
      #   if 'false' then return only names with descendents
      attr_accessor :leaves

      # @return [String, nil]
      #   &taxon_name_type=<Protonym|Combination|Hybrid>
      attr_accessor :taxon_name_type

      # @return [Array]
      attr_accessor :taxon_name_author_ids

      # @return [Boolean]
      # @param [String]
      #    'true'
      attr_accessor :taxon_name_author_ids_or

      # @return [String, nil]
      # @param sort [String, nil]
      #   one of :classification, :alphabetical
      attr_accessor :sort

      # @return [Array]
      #   taxon_name_ids for which all Combinations will be returned
      attr_accessor :combination_taxon_name_id

      # @return [Array]
      # @params rank [String, Array]
      #   The full rank class, or any base, like
      #      NomenclaturalRank::Iczn::SpeciesGroup::Species
      #      Iczn::SpeciesGroup::Species
      attr_accessor :rank

      attr_accessor :geo_json

      # @param params [Params]
      #   as permitted via controller
      def initialize(params)

        @ancestors = boolean_param(params,:ancestors )
        @author = params[:author]
        @author_exact = boolean_param(params, :author_exact)
        @authors = boolean_param(params, :authors )
        @combination_taxon_name_id = params[:combination_taxon_name_id]
        @descendants = boolean_param(params,:descendants )
        @descendants_max_depth = params[:descendants_max_depth]
        @etymology = boolean_param(params, :etymology)
        @geo_json = params[:geo_json]
        @leaves = boolean_param(params, :leaves)
        @name = params[:name]
        @name_exact = boolean_param(params, :name_exact)
        @nomenclature_code = params[:nomenclature_code] if !params[:nomenclature_code].nil?
        @nomenclature_group = params[:nomenclature_group] if !params[:nomenclature_group].nil?
        @not_specified = boolean_param(params, :not_specified)
        @otu_id = params[:otu_id]
        @otus = boolean_param(params, :otus)
        @parent_id = params[:parent_id]
        @project_id = params[:project_id]
        @rank = params[:rank]
        @sort = params[:sort]
        @taxon_name_author_ids = params[:taxon_name_author_ids].blank? ? [] : params[:taxon_name_author_ids]
        @taxon_name_author_ids_or = boolean_param(params, :taxon_name_author_ids_or)
        @taxon_name_classification = params[:taxon_name_classification] || []
        @taxon_name_id = params[:taxon_name_id]
        @taxon_name_relationship = params[:taxon_name_relationship] || []
        @taxon_name_relationship_type = params[:taxon_name_relationship_type] || []
        @taxon_name_type = params[:taxon_name_type]
        @type_metadata = boolean_param(params, :type_metadata)
        @validify = boolean_param(params, :validify)
        @validity = boolean_param(params, :validity)
        @year = params[:year]
        @year_end = params[:year_end]
        @year_start = params[:year_start]

        set_notes_params(params)
        set_data_attributes_params(params)
        set_tags_params(params)
        super
      end

      def year
        return nil if @year.blank?
        @year.to_s
      end

      def name
        [@name].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def combination_taxon_name_id
        [@combination_taxon_name_id].flatten.compact
      end

      def parent_id
        [@parent_id].flatten.compact
      end

      def rank
        [@rank].flatten.compact
      end

      def year_start
        return nil if @year_start.blank?
        Date.new(@year_start.to_i)
      end

      def year_end
        return nil if @year_end.blank?
        Date.new(@year_end.to_i)
      end

      # @return [String, nil]
      #   accessor for attr :nomenclature_group, wrap with needed wildcards
      def nomenclature_group
        return nil unless @nomenclature_group
        "NomenclaturalRank::%#{@nomenclature_group}%"
      end

      # @return [String, nil]
      #   accessor for attr :nomenclature_code, wrap with needed wildcards
      def nomenclature_code
        return nil unless @nomenclature_code
        "NomenclaturalRank::#{@nomenclature_code}%"
      end

      def geo_json_facet
        return nil if geo_json.nil?
        otus = ::Queries::Otu::Filter.new(geo_json: geo_json).all
        collection_objects = ::Queries::CollectionObject::Filter.new(geo_json: geo_json).all

        a = ::TaxonName.joins(:taxon_taxon_determinations).where(taxon_determinations: { biological_collection_object: collection_objects} )
        b = ::TaxonName.joins(:otus).where(otus: otus)

        ::TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
      end

      def not_specified_facet
        return nil if not_specified.nil?
        if not_specified
          ::TaxonName.where(table[:cached].matches("%NOT SPECIFIED%").or(
            table[:cached_original_combination].matches("%NOT SPECIFIED%")))
        else
          ::TaxonName.where(table[:cached].does_not_match("%NOT SPECIFIED%").and(
            table[:cached_original_combination].does_not_match("%NOT SPECIFIED%")))
        end
      end

      # @return Scope
      #   match only names that are a descendant of some taxon_name_id
      # A merge facet.
      def descendant_facet
        return nil if taxon_name_id.empty? || !(descendants == true)

        descendants_subquery = ::TaxonNameHierarchy.where(
          ::TaxonNameHierarchy.arel_table[:descendant_id].eq(::TaxonName.arel_table[:id]).and(
            ::TaxonNameHierarchy.arel_table[:ancestor_id].in(taxon_name_id))
        )

        unless descendants_max_depth.nil? || descendants_max_depth.to_i < 0
          descendants_subquery = descendants_subquery.where(TaxonNameHierarchy.arel_table[:generations].lteq(descendants_max_depth.to_i))
        end

        ::TaxonName.where(descendants_subquery.arel.exists)
      end

      # @return Scope
      #   match only names that are a ancestor of some taxon_name_id
      # A merge facet.
      def ancestor_facet
        return nil if taxon_name_id.empty? || !(ancestors == true)

        ancestors_subquery = ::TaxonNameHierarchy.where(
          ::TaxonNameHierarchy.arel_table[:ancestor_id].eq(::TaxonName.arel_table[:id]).and(
            ::TaxonNameHierarchy.arel_table[:descendant_id].in(taxon_name_id))
        )

        ::TaxonName.where(ancestors_subquery.arel.exists)
      end

      # @return Scope
      def otu_id_facet
        return nil if otu_id.empty?
        ::TaxonName.joins(:otus).where(otus: {id: otu_id})
      end

      # @return Scope
      def otus_facet
        return nil if otus.nil?
        subquery = ::Otu.where(::Otu.arel_table[:taxon_name_id].eq(::TaxonName.arel_table[:id])).arel.exists
        ::TaxonName.where(otus ? subquery : subquery.not)
      end

      # This is not true! It includes records that are year only.
      # @return Scope
      def authors_facet
        return nil if authors.nil?
        authors ?
          ::TaxonName.where.not(cached_author_year: nil) :
          ::TaxonName.where(cached_author_year: nil)
      end

      # @return Scope
      def with_etymology_facet
        return nil if etymology.nil?
        etymology ?
          ::TaxonName.where.not(etymology: nil) :
          ::TaxonName.where(etymology: nil)
      end

      # @return Scope
      def taxon_name_relationship_type_facet
        return nil if taxon_name_relationship_type.empty?
        ::TaxonName.with_taxon_name_relationship(taxon_name_relationship_type)
      end

      # @return Scope
      def leaves_facet
        return nil if leaves.nil?
        leaves ? ::TaxonName.leaves : ::TaxonName.not_leaves
      end

      # @return Scope
      #   wrapped in descendant_facet!
      def taxon_name_relationship_facet(hsh)
        param_key = hsh['subject_taxon_name_id'] ? 'subject_taxon_name_id' : 'object_taxon_name_id'
        join_key = hsh['subject_taxon_name_id'] ? 'object_taxon_name_id' : 'subject_taxon_name_id'

        ::TaxonName.where(
          ::TaxonNameRelationship.where(
            ::TaxonNameRelationship.arel_table[join_key].eq(::TaxonName.arel_table[:id]).and(
              ::TaxonNameRelationship.arel_table[param_key].eq(hsh[param_key])).and(
                ::TaxonNameRelationship.arel_table[:type].eq(hsh['type']))
          ).arel.exists
        )
      end

      # @return Scope
      def taxon_name_classification_facet
        return nil if taxon_name_classification.empty?

        ::TaxonName.where(
          ::TaxonNameClassification.where(
            ::TaxonNameClassification.arel_table[:taxon_name_id].eq(::TaxonName.arel_table[:id]).and(
              ::TaxonNameClassification.arel_table[:type].in(taxon_name_classification))
          ).arel.exists
        )
      end

      # TODO: dry with Source, CollectingEvent , etc.
      def matching_taxon_name_author_ids
        return nil if taxon_name_author_ids.empty?
        o = table
        r = ::Role.arel_table

        a = o.alias("a_")
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
          .and(c[:role_object_type].eq('TaxonName'))
          .and(c[:type].eq('TaxonNameAuthor'))
          )

        e = c[:id].not_eq(nil)
        f = c[:person_id].eq_any(taxon_name_author_ids)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(taxon_name_author_ids.length)) unless taxon_name_author_ids_or
        b = b.as('tn_z1_')

        ::TaxonName.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      # @return Scope
      def type_metadata_facet
        return nil if type_metadata.nil?
        subquery = ::TypeMaterial.where(::TypeMaterial.arel_table[:protonym_id].eq(::TaxonName.arel_table[:id])).arel.exists
        ::TaxonName.where(type_metadata ? subquery : subquery.not)
      end

      # @return Scope
      def otus_facet
        return nil if otus.nil?
        subquery = ::Otu.where(::Otu.arel_table[:taxon_name_id].eq(::TaxonName.arel_table[:id])).arel.exists
        ::TaxonName.where(otus ? subquery : subquery.not)
      end

      # @return [Arel::Nodes::Grouping, nil]
      def with_nomenclature_group
        return nil if nomenclature_group.blank?
        table[:rank_class].matches(nomenclature_group)
      end

      # @return [Arel::Nodes::Grouping, nil]
      def rank_facet
        return nil if rank.blank?
        # We don't wildcard end so that we can isolate to specific ranks and below
        r = rank.collect{|i| "%#{i}"}
        table[:rank_class].matches_any(r)
      end

      # @return [Arel::Nodes::Grouping, nil]
      def with_nomenclature_code
        return nil if nomenclature_code.nil?
        table[:rank_class].matches(nomenclature_code)
      end

      def taxon_name_type_facet
        return nil if taxon_name_type.blank?
        table[:type].eq(taxon_name_type)
      end

      # TODO: Identical use in Otu
      def name_facet
        return nil if name.empty?
        if name_exact
          table[:cached].eq_any(name)
        else
          table[:cached].matches_any( name.collect{|n| '%' + n.gsub(/\s+/, '%') + '%' } )
        end
      end

      def parent_id_facet
        return nil if parent_id.empty?
        table[:parent_id].eq_any(parent_id)
      end

      def author_facet
        return nil if author.blank?
        if author_exact
          table[:cached_author_year].eq(author.strip)
        else
          table[:cached_author_year].matches('%' + author.strip.gsub(/\s/, '%') + '%')
        end
      end

      # TODO: should match against cached_nomenclature_date?
      def year_facet
        return nil if year.blank?
        table[:cached_author_year].matches('%' + year + '%')
      end

      def year_range_facet
        return nil if year_end.nil? && year_start.nil?
        s, e = [year_start, year_end].compact
        ::TaxonName.where(cached_nomenclature_date: (s..e))
      end

      def validity_facet
        return nil if validity.nil?
        if validity
          table[:id].eq(table[:cached_valid_taxon_name_id])
        else
          table[:id].not_eq(table[:cached_valid_taxon_name_id])
        end
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty? || descendants || ancestors
        table[:id].eq_any(taxon_name_id)
      end

      def combination_taxon_name_id_facet
        return nil if combination_taxon_name_id.empty?
        ::Combination.joins(:related_taxon_name_relationships)
          .where(
            taxon_name_relationships: {
              type: ::TAXON_NAME_RELATIONSHIP_COMBINATION_TYPES.values,
              subject_taxon_name_id: combination_taxon_name_id}).distinct
      end

      def otu_query_facet
        return nil if otu_query.nil?
        s = 'WITH query_otu_tn AS (' + otu_query.all.to_sql + ') ' +
          ::TaxonName
          .joins(:otus)
          .joins('JOIN query_otu_tn as query_otu_tn1 on otus.id = query_otu_tn1.id') # Don't change, see `validify`
          .to_sql

        ::TaxonName.from('(' + s + ') as taxon_names').distinct
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_collection_objects AS (' + collection_object_query.all.to_sql + ') ' +
          ::TaxonName
          .joins(:collection_objects)
          .joins('JOIN query_collection_objects as query_collection_objects1 on collection_objects.id = query_collection_objects1.id')
          .to_sql

        ::TaxonName.from('(' + s + ') as taxon_names').distinct
      end

      def collecting_event_query_facet
        return nil if collecting_event_query.nil?
        s = 'WITH query_ce_tns AS (' + collecting_event_query.all.to_sql + ') ' +
          ::TaxonName
          .joins(:collection_objects)
          .joins('JOIN query_ce_tns as query_ce_tns1 on collection_objects.collecting_event_id = query_ce_tns.id')
          .to_sql

        ::TaxonName.from('(' + s + ') as taxon_names').distinct
      end

      # @return [ActiveRecord::Relation]
      def base_and_clauses
        [ 
          author_facet,
          name_facet,
          parent_id_facet,
          rank_facet,
          taxon_name_id_facet,
          taxon_name_type_facet,
          validity_facet,
          with_nomenclature_code,
          with_nomenclature_group,
          year_facet,
        ]
      end

      def base_merge_clauses
        clauses = [
          collection_object_query_facet,
          otu_query_facet,
          source_query_facet,
          
          ancestor_facet,
          authors_facet,
          combination_taxon_name_id_facet,
          descendant_facet,
          leaves_facet,
          matching_taxon_name_author_ids,
          not_specified_facet,
          otu_id_facet,
          otus_facet,
          taxon_name_classification_facet,
          taxon_name_relationship_type_facet,
          type_metadata_facet,
          with_etymology_facet,
          year_range_facet
        ]

        taxon_name_relationship.each do |hsh|
          clauses << taxon_name_relationship_facet(hsh)
        end

        clauses.compact
      end

      def validify_result(q)
        return nil if otu_query.nil?
        s = 'WITH tn_result_query AS (' + q.to_sql + ') ' +
          ::TaxonName
          .joins('JOIN tn_result_query as tn_result_query1 on tn_result_query1.cached_valid_taxon_name_id = taxon_names.id')
          .to_sql

        ::TaxonName.from('(' + s + ') as taxon_names').distinct
      end

      def order_clause(query)
        case sort
        when 'alphabetical'
          ::TaxonName.select('*').from(
            query.order('taxon_names.cached'), :inner_query
          )
        when 'classification'
          ::TaxonName.select('*').from(
            query
            .joins('INNER JOIN taxon_name_hierarchies ON taxon_names.id = taxon_name_hierarchies.descendant_id')
            .order('taxon_name_hierarchies.generations, taxon_name_hierarchies.ancestor_id, taxon_names.cached'),
          :inner_query
          )
        else
          query
        end
      end

      # @return [ActiveRecord::Relation]
      def all
        q = super
        q = validify_result(q) if validify
        q = order_clause(q) if sort
        q
      end

    end
  end
end
