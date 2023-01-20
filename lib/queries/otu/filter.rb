module Queries
  module Otu
    class Filter < Query::Filter

      # TODO: Likely need to sink some queries together (wkt, ce_id) into CO query

      include Queries::Helpers
      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Identifiers
      include Queries::Concerns::Tags

      # Changelog
      # `name` now handles one or more of Otu#name
      # `geographic_area_ids` -> `geographic_area_id
      # `otu_ids` -> `otu_id (String or Array)
      # removed `taxon_name_ids`, allowed Array for `taxon_name_id`
      # created Queries::Concerns::Citations  Citation concern and refactor filters referencing citations accordingly

      PARAMS = [
        :name,
        :name_exact,

        :geographic_area_id,
        :geographic_area_mode,
        :otu_id,
        :taxon_name_id,
        :descendants,
        :collecting_event_id,
        :wkt,
        :geo_json,
        :descriptor_id,

        :observations,

        descriptor_id: [],
        geographic_area_id: [],
        collecting_event_id: [],
        otu_id: [],
        taxon_name_id: [],
        name: []

        # :asserted_distributions,
        # :biological_associations,
        # :contents,
        # :depictions,
        # :exact_author,

        # :taxon_determinations,
        # :author,
        # taxon_name_relationship_ids: [],
        # taxon_name_classification_ids: [],
        # asserted_distribution_ids: [],
      ].freeze

      # @param name [String, Array]
      # @return Array
      #   literal match against one or more Otu#name
      attr_accessor :name

      # @return Boolean
      #   if true then match on `name` exactly
      attr_accessor :name_exact

      # @param otu_id [Integer, Array]
      # @return Array
      #   one or more Otu ids
      attr_accessor :otu_id

      # @param taxon_name_id [Integer, Array]
      # @return Array
      #   one or more Otu taxon_name_id
      attr_accessor :taxon_name_id

      attr_accessor :descendants

      # @param collecting_event_id [Integer, Array]
      # @return Array
      #   one or more collecting_event_id
      # Finds all OTUs that are the current determination of
      # a CollectionObject that was collecting in these
      # Collecting events.
      # Altered by historical_determinations.
      attr_accessor :collecting_event_id

      # @param historical_determinations [Boolean]
      # @return [Boolean, nil]
      # Where applicable:
      #   true - include only historical determinations (ignores only determinations)
      #   false - include both current and historical
      #   nil - include only current determinations
      # Impacts all TaxonDetermination referencing queries
      attr_accessor :historical_determinations

      # @param biological_association_id [Integer, Array]
      # @return Array
      #   one or more biological_association_id
      # Finds all OTUs that are the current determination of
      # a CollectionObject that is in the BiologicalAssociation
      # or are part of the Biological association itself.
      # Altered by historical_determinations.
      attr_accessor :biological_association_id

      # @param asserted_distribution_id [Integer, Array]
      # @return Array
      #   one or more asserted_distribution_id
      # Finds all OTUs that are in these asserted distributions
      attr_accessor :asserted_distribution_id

      # @param wkt [String]
      #  A Spatial area in WKT format
      attr_accessor :wkt

      # @return [Hash, nil]
      #  in geo_json format (no Feature ...) ?!
      attr_accessor :geo_json

      # @param geographic_area_id [String, Array]
      # @return [Array]
      attr_accessor :geographic_area_id

      # TODO: unify across filters (remove spatial etc.)
      # @return [Boolean, nil]
      #   How to treat GeographicAreas
      #     nil - non-spatial match by only those records matching the geographic_area_id exactly
      #     true - spatial match
      #     false - non-spatial match (exact and descendants)
      attr_accessor :geographic_area_mode

      # @return [True, False, nil]
      #   true - Otu has taxon name
      #   false - Otu without taxon name
      #   nil - not applied
      attr_accessor :taxon_name

      # @param descriptor_id [String, Array]
      # @return [Array]
      attr_accessor :descriptor_id

      # -- done to here

      # matching some nomenclature query
      # taxon_name_params

      # matching some set of CollectionObjects
      # collection_object_params
      #   collecting_event_params <- objects

      # NOT USED!
      # via taxon_determinations (collection_object)
      #

      attr_accessor :rank_class

      attr_accessor :author_ids
      attr_accessor :and_or_select

      attr_accessor :biological_associations
      attr_accessor :asserted_distributions
      attr_accessor :exact_author

      # with/out
      attr_accessor :taxon_determinations
      attr_accessor :observations
      attr_accessor :contents
      attr_accessor :depictions # (through specimens/observations ?)

      attr_accessor :author # was verbatim_author_string

      attr_accessor :taxon_name_classification_ids
      attr_accessor :taxon_name_relationship_ids
      attr_accessor :asserted_distribution_ids

      # @param [Hash] params
      def initialize(params)
        # params.reject!{ |_k, v| v.nil? || (v == '') }

        @otu_id = params[:otu_id]
        @taxon_name_id = params[:taxon_name_id]

        @descendants = boolean_param(params, :descendants)

        @name = params[:name]
        @name_exact = boolean_param(params, :name_exact)

        @collecting_event_id = params[:collecting_event_id]

        @historical_determinations = boolean_param(params, :historical_determinations)

        @taxon_name = boolean_param(params, :taxon_name)

        # TODO: perhaps not needed with subqueries now
        @biological_association_id = params[:biological_association_id]

        # TODO: perhaps not needed with subqueries now
        @asserted_distribution_id = params[:asserted_distribution_id]

        @wkt = params[:wkt]
        @geo_json = params[:geo_json]

        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)

        @descriptor_id = params[:descriptor_id]

        # --- done till here ---

        @and_or_select = params[:and_or_select]

        @asserted_distributions = boolean_param(params,:asserted_distributions)
        @biological_associations = boolean_param(params,:biological_associations)
        @contents = boolean_param(params, :contents)
        @depictions = boolean_param(params, :depictions)
        @taxon_determinations = boolean_param(params,:taxon_determinations)
        @citations = params[:citations]
        @observations = boolean_param(params, :observations)

        # @shape = params[:drawn_area_shape]

        @author_ids = params[:author_ids]
        @author = params[:author]
        @exact_author = boolean_param(params, :exact_author)

        @rank_class = params[:rank_class]

        @taxon_name_classification_ids = params[:taxon_name_classification_ids] || []
        @taxon_name_relationship_ids = params[:taxon_name_relationship_ids] || []
        @asserted_distribution_ids = params[:asserted_distribution_ids] || []

        super
      end

      def biological_associations_table
        ::BiologicalAssociation.arel_table
      end

      def descriptor_id
        [@descriptor_id].flatten.compact
      end

      def name
        [@name].flatten.compact.collect{|n| n.strip}
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      def collecting_event_id
        [@collecting_event_id].flatten.compact
      end

      def biological_association_id
        [@biological_association_id].flatten.compact
      end

      def asserted_distribution_id
        [@asserted_distribution_id].flatten.compact
      end

      def otu_id_facet
        return nil if otu_id.empty?
        table[:id].eq_any(otu_id)
      end

      def name_facet
        return nil if name.empty?
        if name_exact
          table[:name].eq_any(name)
        else
          table[:name].matches_any( name.collect{|n| '%' + n.gsub(/\s+/, '%') + '%' } )
        end
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        if descendants
          h = Arel::Table.new(:taxon_name_hierarchies)
          j = table.join(h, Arel::Nodes::InnerJoin).on(table[:taxon_name_id].eq(h[:descendant_id]))
          z = h[:ancestor_id].eq_any(taxon_name_id)

          ::Otu.joins(j.join_sources).where(z)
        else
          ::Otu.where(taxon_name_id: taxon_name_id)
        end
      end

      # TODO: could be optimized with full join pathway perhaps
      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        q = ::Queries::CollectionObject::Filter.new(collecting_event_id: collecting_event_id)
        if historical_determinations.nil?
          ::Otu.joins(:collection_objects).where(collection_objects: q.all, taxon_determinations: {position: 1})
        elsif historical_determinations
          ::Otu.joins(:collection_objects).where(collection_objects: q.all).where.not(taxon_determinations: {position: 1})
        else
          ::Otu.joins(:collection_objects).where(collection_objects: q.all)
        end
      end

      def biological_association_id_facet
        return nil if biological_association_id.empty?

        q = ::BiologicalAssociation.where(id: biological_association_id)

        q1 = ::Otu.joins(:biological_associations).where(biological_associations: {id: q, biological_association_subject_type: 'Otu'})
        q2 = ::Otu.joins(:related_biological_associations).where(related_biological_associations: {id:  q, biological_association_object_type: 'Otu'} )
        q3 = ::Otu.joins(collection_objects: [:biological_associations] ).where(biological_associations: {id: q, biological_association_subject_type: 'CollectionObject'})
        q4 = ::Otu.joins(collection_objects: [:related_biological_associations] ).where(related_biological_associations: {id: q, biological_association_object_type: 'CollectionObject'})

        if historical_determinations.nil?
          q3 = q3.where(taxon_determinations: {position: 1})
          q4 = q4.where(taxon_determinations: {position: 1})
        elsif historical_determinations
          q3 = q3.where.not(taxon_determinations: {position: 1})
          q4 = q4.where.not(taxon_determinations: {position: 1})
        end

        query =  [q1,q2,q3,q4].collect{|s| '(' + s.to_sql + ')'}.join(' UNION ')

        ::Otu.from("(#{query}) as otus")
      end

      def asserted_distribution_id_facet
        return nil if asserted_distribution_id.empty?
        ::Otu.joins(:asserted_distributions).where(asserted_distributions: {id: asserted_distribution_id})
      end

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      # !! TODO: "withify"
      def from_wkt(wkt_shape)
        # !! Need to add nomenclature scope here too ?!

        c = ::Queries::CollectingEvent::Filter.new(wkt: wkt_shape)
        a = ::Queries::AssertedDistribution::Filter.new(wkt: wkt_shape)

        q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all)
        q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all)

        ::Otu.from("((#{q1.to_sql}) UNION (#{q2.to_sql})) as otus")
      end

      # !! TODO: Scope to projects
      # !! TODO: "withify"
      def geo_json_facet
        return nil if geo_json.nil?

        c = ::Queries::CollectingEvent::Filter.new(geo_json: geo_json).all.where(project_id: project_id)
        a = ::Queries::AssertedDistribution::Filter.new(geo_json: geo_json).all.where(project_id: project_id)

        #  q1 = 'WITH ces_geo_json AS (' + c.all.to_sql + ')' +
        #     ::Otu
        #     .joins(:collecting_events)
        #     .joins('JOIN ces_geo_json as ces_geo_json1 on collecting_events.id = ces_geo_json1.id')
        #     .to_sql      

        #  
        #  q2 = 'WITH ads_geo_json AS (' + a.all.to_sql + ') ' +
        #     ::Otu
        #     .joins(:asserted_distributions)
        #     .joins('JOIN ads_geo_json as ads_geo_json1 on asserted_distributions.id = ads_geo_json1.id')
        #     .to_sql


        # Seems IN or WITH ^ seem to be identical 
        q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all).to_sql
        q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all).to_sql

        ::Otu.from("((#{q1}) UNION (#{q2})) as otus")
      end

      def geographic_area_id_facet
        return nil if geographic_area_id.empty?

        a = nil

        case geographic_area_mode
        when nil, true # exact and spatial start the same
          a = ::GeographicArea.where(id: geographic_area_id)
        when false # descendants
          a = ::GeographicArea.descendants_of_any(geographic_area_id)
        end

        b = nil # from AssertedDistributions
        c = nil # from CollectionObjects

        case geographic_area_mode
        when nil, false # exact, descendants
          b = ::Otu.joins(:asserted_distributions).where(asserted_distributions: {geographic_area: a})
          c = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: {geographic_area: a} )
        when true # spatial
          i = ::GeographicItem.joins(:geographic_areas).where(geographic_areas: a) # .unscope
          wkt_shape = ::GeographicItem.st_union(i).to_a.first['collection'].to_s # todo, check
          return from_wkt(wkt_shape)
        end

        ::Otu.from("((#{b.to_sql}) UNION (#{c.to_sql})) as otus")
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        s = 'WITH query_taxon_names AS (' + taxon_name_query.all.to_sql + ') ' +
          ::Otu
          .joins(:taxon_name)
          .joins('JOIN query_taxon_names as query_taxon_names1 on otus.taxon_name_id = query_taxon_names1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus')
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_otus AS (' + collection_object_query.all.to_sql + ') ' +
          ::Otu
          .joins(:collection_objects)
          .joins('JOIN query_co_otus as query_co_otus1 on collection_objects.id = query_co_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus')
      end

      def collecting_event_query_facet
        return nil if collecting_event_query.nil?
        s = 'WITH query_ce_otus AS (' + collecting_event_query.all.to_sql + ') ' +
          ::Otu
          .joins(:collecting_events)
          .joins('JOIN query_ce_otus as query_ce_otus1 on collecting_events.id = query_ce_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus')
      end

      # TODO: Validate
      def extract_query_facet
        return nil if extract_query.nil?
        s = 'WITH query_ex_otus AS (' + extract_query.all.to_sql + ') ' +
          ::Otu
          .joins(:extracts)
          .joins('JOIN query_ex_otus as query_ex_otu1s on extracts.id = query_ex_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus')
      end

      # TODO: Validate
      def asserted_distributions_facet
        return nil if asserted_distribution_query.nil?
        s = 'WITH query_ad_otus AS (' + asserted_distribution_query.all.to_sql + ') ' +
          ::Otu
          .joins('JOIN query_ad_otus as query_ad_otus1 on otus.id = query_ad_otus.otu_id')
          .to_sql

        ::Otu.from('(' + s + ') as otus')
      end

      # ----

      # @return [Boolean]
      def author_set?
        case author_ids
        when nil
          false
        else
          author_ids.count > 0
        end
      end

      # ---

      # TODO: deprecate to biological associtations.
      def biological_associations_facet
        return nil if biological_associations.nil?
        subquery = ::BiologicalAssociation.where(::BiologicalAssociation.arel_table[:biological_association_subject_id].eq(::Otu.arel_table[:id]).and(
          ::BiologicalAssociation.arel_table[:biological_association_subject_type].eq('Otu'))
                                                ).arel.exists
                                                ::Otu.where(biological_associations ? subquery : subquery.not)
      end

      def asserted_distributions_facet
        return nil if asserted_distributions.nil?

        subquery = ::AssertedDistribution.where(::AssertedDistribution.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
        ::Otu.where(asserted_distributions ? subquery : subquery.not)
      end

      def determinations_facet
        return nil if taxon_determinations.nil?

        subquery = ::TaxonDetermination.where(::TaxonDetermination.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
        ::Otu.where(taxon_determinations ? subquery : subquery.not)
      end

      def taxon_name_facet
        return nil if taxon_name.nil?

        if taxon_name
          table[:taxon_name_id].eq(nil)
        else
          table[:taxon_name_id].not_eq(nil)
        end
      end

      def depictions_facet
        return nil if depictions.nil?
        subquery = ::Depiction.where(::Depiction.arel_table[:depiction_object_id].eq(::Otu.arel_table[:id]).and(
          ::Depiction.arel_table[:depiction_object_type].eq('Otu'))).arel.exists
        ::Otu.where(depictions ? subquery : subquery.not)
      end

      def descriptor_id_facet
        return nil if descriptor_id.empty?

        q1 = ::Otu.joins(:descriptors).where(descriptors: {id: descriptor_id})
        q2 = ::Otu.joins(collection_objects: [:descriptors]).where(descriptors: {id: :descriptor_id})

        ::Otu.from("((#{q1.to_sql}) UNION (#{q2.to_sql})) as otus")
      end

      def observations_facet
        return nil if observations.nil?

        if observations
          ::Otu.joins(:observation_matrix_rows)
        else
          ::Otu.where.missing(:observation_matrix_rows)
        end

        #       subquery = ::ObservationMatrixRow.where(::ObservationMatrixRow.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
        #       ::Otu.where(observations ? subquery : subquery.not)
      end

      def contents_facet
        return nil if contents.nil?

        subquery = ::Content.where(::Content.arel_table[:otu_id].eq(::Otu.arel_table[:id])).arel.exists
        ::Otu.where(contents ? subquery : subquery.not)
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          otu_id_facet,
          name_facet,
          taxon_name_facet

          # matching_verbatim_author
          # Queries::Annotator.annotator_params(options, ::Citation),
        ].compact
      end

      def merge_clauses
        [
          source_query_facet,
          collection_object_query_facet,
          collecting_event_query_facet,

          descriptor_id_facet,
          observations_facet,
          taxon_name_query_facet,
          taxon_name_id_facet,
          geo_json_facet,
          collecting_event_id_facet,
          biological_association_id_facet,
          asserted_distribution_id_facet,
          wkt_facet,
          geographic_area_id_facet,

          #  asserted_distributions_facet,
          #  biological_associations_facet,
          #  contents_facet,
          #  depictions_facet,
          #  determinations_facet,
          #  observations_facet,
          #  verbatim_author_facet
          # matching_verbatim_author
        ].compact
      end

    end
  end
end

