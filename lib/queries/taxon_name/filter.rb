module Queries
  module TaxonName
    class Filter < Query::Filter
      include Queries::Helpers

      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Depictions
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags

      PARAMS = [
        :ancestors,
        :ancestrify,
        :author,
        :author_exact,
        :authors,
        :collecting_event_id,
        :collection_object_id,
        :combinations,
        :combinationify,
        :descendants,
        :descendants_max_depth,
        :epithet_only,
        :etymology,
        :leaves,
        :name,
        :name_exact,
        :nomenclature_code,
        :nomenclature_date,
        :nomenclature_group, # !! different than autocomplete
        :not_specified,
        :original_combination,
        :otu_id,
        :otus,
        :rank,
        :synonymify,
        :taxon_name_author_id_or,
        :taxon_name_id,
        :taxon_name_type,
        :type_metadata,
        :validify,
        :validity,
        :year,
        :year_end,
        :year_start,

        collection_object_id: [],
        collecting_event_id: [],
        combination_taxon_name_id: [],
        name: [],
        otu_id: [],
        parent_id: [],
        rank: [],
        taxon_name_author_id: [],
        taxon_name_classification: [],
        taxon_name_id: [],
        taxon_name_relationship: [
          :subject_taxon_name_id,
          :object_taxon_name_id,
          :type,
        ],
        taxon_name_relationship_type: [],
        type: [],
      ].freeze

      # @param ancestors [Boolean, 'true', 'false', nil]
      # @return Boolean
      #   Ignored when taxon_name_id[].empty?  Works as AND clause with descendants :(
      attr_accessor :ancestors

      # @param ancestrify [Boolean]
      #   true - extend result to include all ancestors of names in the result along with the result
      #   false/nil - ignore
      # !! This parameter is not like the others, it is applied POST result, see also synonymify and validify, etc.
      attr_accessor :ancestrify

      # @param epithet_only [Boolean]
      #   true - use name property instead of cached to find taxon name
      #   false/nil - ignore
      attr_accessor :epithet_only

      # @param collection_object_id[String, Array]
      # @return Array
      attr_accessor :collection_object_id

      # @param combinations [Boolean]
      #   true - only return names that have (subsequent) Combinations
      #   false - only return names without (subequent) Combinations
      #   nil - ignore
      # This parameter should be used along side species or genus group limits.
      attr_accessor :combinations

      # @param combinationify [Boolean]
      #   true - extend result to include all Combinations in which the finest name is a member of the result
      #   false/nil - ignore
      # !! This parameter is not like the others, it is applied POST result, see also synonymify and validify
      attr_accessor :combinationify

      # @param collection_object_id[String, Array]
      # @return Array
      attr_accessor :collection_object_id

      # @param collecting_event_id [String, Array]
      # @return Array
      attr_accessor :collecting_event_id

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

      # @param ancestors [Boolean, 'true', 'false', nil]
      # @return Boolean
      #   with/out cached nomenclature date set
      attr_accessor :nomenclature_date

      # @param year_start [String]
      #   "yyyy"
      # Matches against cached_nomenclature_date
      attr_accessor :year_start

      # @param year_end [String]
      #   "yyyy"
      # Matches against cached_nomenclature_date
      attr_accessor :year_end

      # @params validity [ Boolean]
      # ['true' or 'false'] on initialize
      #   true if only valid, false if only invalid, nil if both
      attr_accessor :validity

      # @params validify ['true', True, nil]
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

      # @param descendants [Boolean, 'true', 'false', nil]
      #   Read carefully! descendants = false is NOT no descendants, it's descendants and self
      # @return [Boolean]
      #   true - only descendants NOT SELF
      #   false - self AND descendants
      #   nil - ignored
      #   Ignored when taxon_name_id[].empty?
      attr_accessor :descendants

      # @param descendants_max_depth [Integer]
      # @return [Integer, nil]
      # A positive integer indicating how many levels deep of descendants to retrieve.
      #   Ignored when descentants is false/unspecified.
      #   Defaults to nil
      attr_accessor :descendants_max_depth

      # @param synonymify [Boolean]
      #   true - extend result to include all Synonyms of any member of the list
      #   false/nil - ignore
      # !! This parameter is not like the others, it is applied POST result, see also combinationify and validify
      attr_accessor :synonymify

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

      # @param original_combination [Boolean]
      # @return [Boolean, nil]
      #   true - name has at least one element of original combination
      #   false - name has no element of original combination
      #   nil - ignored
      attr_accessor :original_combination

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
      attr_accessor :taxon_name_author_id

      # @return [Boolean]
      # @param [String]
      #   `false`, nil - treat the ids in taxon_name_author_id as "or" (match any TaxonName with any of these authors)
      #   'true' - treat the ids in taxon_name_author_id as "and" (only TaxonNames with all and only all will match)
      attr_accessor :taxon_name_author_id_or

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
      def initialize(query_params)
        super

        @ancestors = boolean_param(params, :ancestors)
        @ancestrify = boolean_param(params, :ancestrify)
        @author = params[:author]
        @author_exact = boolean_param(params, :author_exact)
        @authors = boolean_param(params, :authors)
        @collecting_event_id = params[:collecting_event_id]
        @collection_object_id = params[:collection_object_id]
        @combination_taxon_name_id = params[:combination_taxon_name_id]
        @combinations = boolean_param(params, :combinations)
        @combinationify = boolean_param(params, :combinationify)
        @descendants = boolean_param(params, :descendants)
        @descendants_max_depth = params[:descendants_max_depth]
        @etymology = boolean_param(params, :etymology)
        @epithet_only = params[:epithet_only]
        @geo_json = params[:geo_json]
        @leaves = boolean_param(params, :leaves)
        @name = params[:name]
        @name_exact = boolean_param(params, :name_exact)
        @nomenclature_date = boolean_param(params, :nomenclature_date)
        @nomenclature_code = params[:nomenclature_code] if params[:nomenclature_code].present?
        @nomenclature_group = params[:nomenclature_group] if params[:nomenclature_group].present?
        @not_specified = boolean_param(params, :not_specified)
        @otu_id = params[:otu_id]
        @otus = boolean_param(params, :otus)
        @original_combination = boolean_param(params, :original_combination)
        @parent_id = params[:parent_id]
        @rank = params[:rank]
        @sort = params[:sort]
        @synonymify = boolean_param(params, :synonymify)
        @taxon_name_author_id = params[:taxon_name_author_id]
        @taxon_name_author_id_or = boolean_param(params, :taxon_name_author_id_or)
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

        set_citations_params(params)
        set_depiction_params(params)
        set_notes_params(params)
        set_data_attributes_params(params)
        set_tags_params(params)
      end

      def taxon_name_author_id
        [@taxon_name_author_id].flatten.compact
      end

      def year
        return nil if @year.blank?
        @year.to_s
      end

      def name
        [@name].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def year
        return nil if @year.blank?
        @year.to_s
      end

      def name
        [@name].flatten.compact
      end

      def collection_object_id
        [@collection_object_id].flatten.compact
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact
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
        Date.new(@year_end.to_i, 12, 31)
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
        otus = ::Queries::Otu::Filter.new(geo_json:).all
        collection_objects = ::Queries::CollectionObject::Filter.new(geo_json:).all

        a = ::TaxonName.joins(:taxon_taxon_determinations).where(taxon_determinations: { taxon_determination_object: collection_objects })
        b = ::TaxonName.joins(:otus).where(otus:)

        ::TaxonName.from("((#{a.to_sql}) UNION (#{b.to_sql})) as taxon_names")
      end

      def not_specified_facet
        return nil if not_specified.nil?
        if not_specified
          ::TaxonName.where(table[:cached].matches('%NOT SPECIFIED%').or(
            table[:cached_original_combination].matches('%NOT SPECIFIED%')
          ))
        else
          ::TaxonName.where(table[:cached].does_not_match('%NOT SPECIFIED%').and(
            table[:cached_original_combination].does_not_match('%NOT SPECIFIED%')
          ))
        end
      end

      def original_combination_facet
        return nil if original_combination.nil?
        if original_combination
          ::Protonym.joins(:original_combination_relationships)
        else
          ::Protonym.where.missing(:original_combination_relationships)
        end
      end

      def nomenclature_date_facet
        return nil if nomenclature_date.nil?
        if nomenclature_date
          table[:cached_nomenclature_date].not_eq(nil)
        else
          table[:cached_nomenclature_date].eq(nil)
        end
      end

      # @return Scope
      #   match only names that are a descendant of some taxon_name_id
      def descendant_facet
        return nil if taxon_name_id.empty? || descendants.nil?

        h = ::TaxonNameHierarchy.arel_table

        if descendants
          descendants_subquery = ::TaxonNameHierarchy.where(
            h[:descendant_id].eq(::TaxonName.arel_table[:id]).and(
              h[:ancestor_id].in(taxon_name_id)
            )
          ).where(h[:ancestor_id].not_eq(h[:descendant_id]))

          if descendants_max_depth.present?
            descendants_subquery = descendants_subquery.where(::TaxonNameHierarchy.arel_table[:generations].lteq(descendants_max_depth.to_i))
          end

          ::TaxonName.where(descendants_subquery.arel.exists)
        else
          q = ::TaxonName.joins('JOIN taxon_name_hierarchies ON taxon_name_hierarchies.descendant_id = taxon_names.id')
            .where(taxon_name_hierarchies: {ancestor_id: taxon_name_id})
           if descendants_max_depth.present?
             q = q.where(::TaxonNameHierarchy.arel_table[:generations].lteq(descendants_max_depth.to_i))
           end
           q
        end
      end

      # @return Scope
      #   match only names that are a ancestor of some taxon_name_id
      # A merge facet.
      def ancestor_facet
        return nil if taxon_name_id.empty? || !(ancestors == true)

        ancestors_subquery = ::TaxonNameHierarchy.where(
          ::TaxonNameHierarchy.arel_table[:ancestor_id].eq(::TaxonName.arel_table[:id]).and(
            ::TaxonNameHierarchy.arel_table[:descendant_id].in(taxon_name_id)
          )
        )

        ::TaxonName.where(ancestors_subquery.arel.exists)
      end

      def collection_object_id_facet
        return nil if collection_object_id.empty?
        ::TaxonName.joins(:collection_objects).where(collection_objects: { id: collection_object_id })
      end

      def otu_id_facet
        return nil if otu_id.empty?
        ::TaxonName.joins(:otus).where(otus: { id: otu_id })
      end

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
              ::TaxonNameRelationship.arel_table[param_key].eq(hsh[param_key])
            ).and(
              ::TaxonNameRelationship.arel_table[:type].eq(hsh['type'])
            )
          ).arel.exists
        )
      end

      # @return Scope
      def taxon_name_classification_facet
        return nil if taxon_name_classification.empty?

        ::TaxonName.where(
          ::TaxonNameClassification.where(
            ::TaxonNameClassification.arel_table[:taxon_name_id].eq(::TaxonName.arel_table[:id]).and(
              ::TaxonNameClassification.arel_table[:type].in(taxon_name_classification)
            )
          ).arel.exists
        )
      end

      def taxon_name_author_id_facet
        return nil if taxon_name_author_id.empty?
        o = table
        r = ::Role.arel_table

        a = o.alias('a_')
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
              .and(c[:role_object_type].eq('TaxonName'))
              .and(c[:type].eq('TaxonNameAuthor'))
          )

        e = c[:id].not_eq(nil)
        f = c[:person_id].in(taxon_name_author_id)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(taxon_name_author_id.length)) unless taxon_name_author_id_or
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
        r = rank.collect { |i| "%#{i}" }
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

      def name_facet
        return nil if name.empty?
        if name_exact
          if (epithet_only)
            table[:name].in(name)
          else
            table[:cached].in(name).or(table[:cached_original_combination].in(name))
          end
          #  table[:cached].eq(name.strip).or(table[:cached_original_combination].eq(name.strip))
        else
          if (epithet_only)
            table[:name].matches_any(name.collect { |n| '%' + n.gsub(/\s+/, '%') + '%' })
          else
            table[:cached].matches_any(name.collect { |n| '%' + n.gsub(/\s+/, '%') + '%' }).or(table[:cached_original_combination].matches_any(name.collect { |n| '%' + n.gsub(/\s+/, '%') + '%' }))
          end
        end
      end

      def parent_id_facet
        return nil if parent_id.empty?
        table[:parent_id].in(parent_id)
      end

      def author_facet
        return nil if author.blank?
        if author_exact
          table[:cached_author_year].eq(author.strip)
        else
          table[:cached_author_year].matches('%' + author.strip.gsub(/\s/, '%') + '%')
        end
      end

      def year_facet
        return nil if year.blank?

        s = Date.new(@year.to_i)
        e = Date.new(@year.to_i, 12, 31)
        table[:cached_nomenclature_date].between(s..e)
      end

      def year_range_facet
        return nil if year_end.nil? && year_start.nil?
        s, e = [year_start, year_end].compact
        ::TaxonName.where(cached_nomenclature_date: (s..e))
      end

      def validity_facet
        return nil if validity.nil?
        if validity
          table[:cached_is_valid].eq(true)
        else
          table[:cached_is_valid].eq(false)
        end
      end

      def combination_taxon_name_id_facet
        return nil if combination_taxon_name_id.empty?
        ::Combination.joins(:related_taxon_name_relationships)
          .where(
            taxon_name_relationships: {
              type: ::TAXON_NAME_RELATIONSHIP_COMBINATION_TYPES.values,
              subject_taxon_name_id: combination_taxon_name_id,
            },
          ).distinct
      end

      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        ::TaxonName
          .joins(:collection_objects)
          .where(collection_objects: { collecting_event_id: })
      end

      def combinations_facet
        return nil if combinations.nil?
        a = ::Protonym.joins(:combination_relationships)
        if combinations
          a
        else
          referenced_klass_except(a)
        end
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

      def asserted_distribution_query_facet
        return nil if asserted_distribution_query.nil?
        s = 'WITH query_ad_tn AS (' + asserted_distribution_query.all.to_sql + ') ' +
            ::TaxonName
              .joins(otus: [:asserted_distributions])
              .joins('JOIN query_ad_tn as query_ad_tn1 on query_ad_tn1.otu_id = asserted_distributions.otu_id')
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
              .joins('JOIN query_ce_tns as query_ce_tns1 on collection_objects.collecting_event_id = query_ce_tns1.id')
              .to_sql

        ::TaxonName.from('(' + s + ') as taxon_names').distinct
      end

      def biological_association_query_facet
        return nil if biological_association_query.nil?
        s = 'WITH query_tn_ba AS (' + biological_association_query.all.to_sql + ') '

        a = ::TaxonName
          .joins(:otus)
          .joins("JOIN query_tn_ba as query_tn_ba1 on query_tn_ba1.biological_association_subject_id = otus.id AND query_tn_ba1.biological_association_subject_type = 'Otu'").to_sql

        b = ::TaxonName
          .joins(:otus)
          .joins("JOIN query_tn_ba as query_tn_ba2 on query_tn_ba2.biological_association_object_id = otus.id AND query_tn_ba2.biological_association_object_type = 'Otu'").to_sql

        s << ::TaxonName.from("((#{a}) UNION (#{b})) as taxon_names").to_sql

        ::TaxonName.from('(' + s + ') as taxon_names')
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        [
          nomenclature_date_facet,
          author_facet,
          name_facet,
          parent_id_facet,
          rank_facet,
          taxon_name_type_facet,
          validity_facet,
          with_nomenclature_code,
          with_nomenclature_group,
          year_facet,
        ]
      end

      def merge_clauses
        clauses = [
          asserted_distribution_query_facet,
          biological_association_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          otu_query_facet,

          ancestor_facet,
          authors_facet,
          collecting_event_id_facet,
          collection_object_id_facet,
          combination_taxon_name_id_facet,
          combinations_facet,
          descendant_facet,
          leaves_facet,
          not_specified_facet,
          original_combination_facet,
          otu_id_facet,
          taxon_name_author_id_facet,
          otus_facet,
          taxon_name_classification_facet,
          taxon_name_relationship_type_facet,
          type_metadata_facet,
          with_etymology_facet,
          year_range_facet,
        ]

        taxon_name_relationship.each do |hsh|
          clauses << taxon_name_relationship_facet(hsh)
        end

        clauses.compact
      end

      # Overrides base class
      def model_id_facet
        return nil if taxon_name_id.empty? || !descendants.nil? || ancestors
        table[:id].in(taxon_name_id)
      end

      def validify_result(q)
        s = 'WITH tn_result_query AS (' + q.to_sql + ') ' +
            ::TaxonName
              .joins('JOIN tn_result_query as tn_result_query1 on tn_result_query1.cached_valid_taxon_name_id = taxon_names.id')
              .to_sql

        ::TaxonName.from('(' + s + ') as taxon_names').distinct
      end

      def synonimify_result(q)
        s = 'WITH tn_result_query AS (' + q.to_sql + ') ' +
            ::TaxonName
              .joins('JOIN tn_result_query as tn_result_query2 on tn_result_query2.id = taxon_names.cached_valid_taxon_name_id')
              .to_sql

        a = ::TaxonName.from('(' + s + ') as taxon_names').distinct

        referenced_klass_union([q, a])
      end

      def combinationify_result(q)
        s = 'WITH tn_result_query AS (' + q.to_sql + ') ' +
            ::TaxonName
              .joins('JOIN tn_result_query as tn_result_query3 on tn_result_query3.id = taxon_names.cached_valid_taxon_name_id')
              .where("taxon_names.type = 'Combination'")
              .to_sql

        a = ::TaxonName.from('(' + s + ') as taxon_names').distinct

        referenced_klass_union([q, a])
      end

      def ancestrify_result(q)
        s = 'WITH tn_result_query_anc AS (' + q.to_sql + ') ' +
            ::TaxonName
              .joins('JOIN taxon_name_hierarchies tnh on tnh.ancestor_id = taxon_names.id')
              .joins('JOIN tn_result_query_anc as tn_result_query_anc1 on tn_result_query_anc1.id = tnh.descendant_id')
              .distinct
              .to_sql

        # !! Do not use .distinct here
        ::TaxonName.from('(' + s + ') as taxon_names')
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
      def all(nil_empty = false)
        q = super

        # Order matters, use this first to go up
        q = ancestrify_result(q) if ancestrify

        # Then out in various ways
        q = validify_result(q) if validify
        q = combinationify_result(q) if combinationify
        q = synonimify_result(q) if synonymify

        # Then sort
        q = order_clause(q) if sort

        q
      end
    end
  end
end
