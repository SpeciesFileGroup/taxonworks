module Queries
  module Otu
    class Filter < Query::Filter

      # TODO: Likely need to sink some queries together (wkt, ce_id) into CO query

      include Queries::Helpers
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Tags

      # Changelog
      # `name` now handles one or more of Otu#name
      # `geographic_area_ids` -> `geographic_area_id
      # `otu_ids` -> `otu_id (String or Array)
      # removed `taxon_name_ids`, allowed Array for `taxon_name_id`
      # created Queries::Concerns::Citations  Citation concern and refactor filters referencing citations accordingly

      PARAMS = [
        :asserted_distribution_id,
        :asserted_distributions,
        :biological_association_id,
        :biological_associations,
        :collecting_event_id,
        :collection_objects,
        :contents,
        :depictions,
        :descendants,
        :descriptor_id,
        :geo_json,
        :geographic_area_id,
        :geographic_area_mode,
        :name,
        :name_exact,
        :observations,
        :otu_id,
        :taxon_name,
        :taxon_name_id,
        :wkt,

        asserted_distribution_id: [],
        collecting_event_id: [],
        descriptor_id: [],
        geographic_area_id: [],
        name: [],
        otu_id: [],
        taxon_name_id: [],
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

      # @return [True, False, nil]
      #   true - Otu has AssertedDistribution
      #   false - Otu without AssertedDistribution
      #   nil - not applied
      attr_accessor :asserted_distributions

      # @return [True, False, nil]
      #   true - Otu has Conten
      #   false - Otu without Conten
      #   nil - not applied
      attr_accessor :contents

      # @return [True, False, nil]
      #   true - Otu has Depictions
      #   false - Otu without Depictions
      #   nil - not applied
      #  Currently applies only directly on OTU
      attr_accessor :depictions

      # @return [True, False, nil]
      #   true - Otu has CollectionObjects
      #   false - Otu without CollectionObjects
      #   nil - not applied
      attr_accessor :collection_objects

      # @return [True, False, nil]
      #   true - Otu has TaxonName
      #   false - Otu without TaxonName
      #   nil - not applied
      attr_accessor :taxon_name

      # @return [True, False, nil]
      #   true - Otu has BiologicalAssocation (subject or object)
      #   false - Otu without BiologicalAssociation
      #   nil - not applied
      attr_accessor :biological_associations

      # @return [True, False, nil]
      #   true - Otu has observations
      #   false - Otu without observations
      #   nil - not applied
      attr_accessor :observations

      # @return Array
      #   from these asserted distributions
      attr_accessor :asserted_distribution_id

      def initialize(params)
        @asserted_distribution_id = params[:asserted_distribution_id]
        @asserted_distributions = boolean_param(params,:asserted_distributions)
        @biological_association_id = params[:biological_association_id]
        @biological_associations = boolean_param(params,:biological_associations)
        @collecting_event_id = params[:collecting_event_id]
        @collection_objects = boolean_param(params, :collection_objects)
        @contents = boolean_param(params, :contents)
        @depictions = boolean_param(params, :depictions)
        @descendants = boolean_param(params, :descendants)
        @descriptor_id = params[:descriptor_id]
        @geo_json = params[:geo_json]
        @geographic_area_id = params[:geographic_area_id]
        @geographic_area_mode = boolean_param(params, :geographic_area_mode)
        @historical_determinations = boolean_param(params, :historical_determinations)
        @name = params[:name]
        @name_exact = boolean_param(params, :name_exact)
        @observations = boolean_param(params, :observations)
        @otu_id = params[:otu_id]
        @taxon_name = boolean_param(params, :taxon_name)
        @taxon_name_id = params[:taxon_name_id]
        @wkt = params[:wkt]

        set_data_attributes_params(params)
        set_tags_params(params)
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

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      def from_wkt(wkt_shape)
        c = ::Queries::CollectingEvent::Filter.new(wkt: wkt_shape, project_id: project_id)
        a = ::Queries::AssertedDistribution::Filter.new(wkt: wkt_shape, project_id: project_id)

        q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all)
        q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all)

        ::Otu.from("((#{q1.to_sql}) UNION (#{q2.to_sql})) as otus")
      end

      def geo_json_facet
        return nil if geo_json.nil?

        c = ::Queries::CollectingEvent::Filter.new(geo_json: geo_json, project_id: project_id)
        a = ::Queries::AssertedDistribution::Filter.new(geo_json: geo_json, project_id: project_id)

        q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all).to_sql
        q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all).to_sql

        ::Otu.from("((#{q1}) UNION (#{q2})) as otus")
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
      def asserted_distributions_query_facet
        return nil if asserted_distribution_query.nil?
        s = 'WITH query_ad_otus AS (' + asserted_distribution_query.all.to_sql + ') ' +
          ::Otu
          .joins('JOIN query_ad_otus as query_ad_otus1 on otus.id = query_ad_otus.otu_id')
          .to_sql

        ::Otu.from('(' + s + ') as otus')
      end

      def content_query_facet
        return nil if content_query.nil?
        s = 'WITH query_con_otus AS (' + content_query.all.to_sql + ') ' +
          ::Otu
          .joins('JOIN query_con_otus as query_con_otus1 on otus.id = query_con_otus1.otu_id')
          .to_sql

        ::Otu.from('(' + s + ') as otus')
      end

      def asserted_distributions_facet
        return nil if asserted_distributions.nil?
        if asserted_distributions
          ::Otu.joins(:asserted_distributions)
        else
          ::Otu.where.missing(:asserted_distributions)
        end
      end

      def contents_facet
        return nil if contents.nil?
        if contents
          ::Otu.joins(:contents)
        else
          ::Otu.where.missing(:contents)
        end
      end

      # UNION, NOT EXISTS example
      def biological_associations_facet
        return nil if biological_associations.nil?

        a = ::Otu.joins(:biological_associations)
        b = ::Otu.joins(:related_biological_associations)

        c = ::Otu.from("((#{a.to_sql}) UNION (#{b.to_sql})) as otus")

        if biological_associations
          ::Otu.from("((#{a.to_sql}) UNION (#{b.to_sql})) as otus")
        else
          ::Otu.where( 'NOT EXISTS (' + ::Otu.select('1').from(    # not exists ( a select(1) from <opposite query>  )
                                                               ::Otu.from(
                                                                 "((#{a.to_sql}) UNION (#{b.to_sql})) as ba_otus_join"
                                                               ).where('otus.id = ba_otus_join.id') ).to_sql  + ')' )  # where includes in/out link
        end
      end

      def depictions_facet
        return nil if depictions.nil?
        if depictions
          ::Otu.joins(:depictions)
        else
          ::Otu.where.missing(:depitions)
        end
      end

      def collection_objects_facet
        return nil if collection_objects.nil?
        if collection_objects
          ::Otu.joins(:collection_objects)
        else
          ::Otu.where.missing(:collection_objects)
        end
      end

      def taxon_name_facet
        return nil if taxon_name.nil?

        if taxon_name
          table[:taxon_name_id].eq(nil)
        else
          table[:taxon_name_id].not_eq(nil)
        end
      end

      def observations_facet
        return nil if observations.nil?

        if observations
          ::Otu.joins(:observations)
        else
          ::Otu.where.missing(:observations)
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

      def descriptor_id_facet
        return nil if descriptor_id.empty?

        q1 = ::Otu.joins(:descriptors).where(descriptors: {id: descriptor_id})
        q2 = ::Otu.joins(collection_objects: [:descriptors]).where(descriptors: {id: descriptor_id})

        ::Otu.from("((#{q1.to_sql}) UNION (#{q2.to_sql})) as otus")
      end

      def and_clauses
        [
          otu_id_facet,
          name_facet,
          taxon_name_facet
        ]
      end

      def merge_clauses
        [
          source_query_facet,
          collection_object_query_facet,
          collecting_event_query_facet,
          content_query_facet,

          asserted_distribution_id_facet,
          asserted_distributions_facet,
          biological_association_id_facet,
          biological_associations_facet,
          collecting_event_id_facet,
          collection_objects_facet,
          contents_facet,
          depictions_facet,
          descriptor_id_facet,
          geo_json_facet,
          geographic_area_id_facet,
          observations_facet,
          taxon_name_id_facet,
          taxon_name_query_facet,
          wkt_facet,
        ].compact
      end

    end
  end
end

