module Queries
  module Otu
    class Filter < Query::Filter
      include Queries::Concerns::Citations
      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Depictions
      include Queries::Concerns::Gazetteers
      include Queries::Concerns::Tags
      include Queries::Concerns::Notes
      include Queries::Concerns::Confidences
      include Queries::Helpers

      PARAMS = [
        :ancestrify,
        :asserted_distributions,
        :biological_association_id,
        :biological_associations,
        :collecting_event_id,
        :collection_objects,
        :common_names,
        :contents,
        :coordinatify,
        :descendants,
        :descriptor_id,
        :geo_json,
        :gazetteer_id,
        :geographic_area_id,
        :geographic_area_mode,
        :name,
        :name_exact,
        :observations,
        :otu_id,
        :radius,
        :taxon_name,
        :taxon_name_id,
        :with_name,
        :wkt,

        collecting_event_id: [],
        descriptor_id: [],
        gazetteer_id: [],
        geographic_area_id: [],
        name: [],
        otu_id: [],
        taxon_name_id: [],
      ].freeze

      # @params ancestrify ['true', True, nil]
      # @return Boolean
      #    if true then, additionally, all coordinate otus for all inferred ancestors are included
      #    the param adds to the result by going "up" (to root) _then_ "out"
      #
      # !! This param is not like the others. !!  See parallel in TaxonName filter 'ancestrify'.
      attr_accessor :ancestrify

      # @params coordinatify ['true', True, nil]
      # @return Boolean
      #    if true then, additionally, all coordinate otus for the result are included
      # See `coordinatify_result` for more.
      #
      # !! This param is not like the others. !!  See parallel in TaxonName filter 'validify'.
      attr_accessor :coordinatify

      # @param name [String, Array]
      # @return Array
      #   literal match against one or more Otu#name
      attr_accessor :name

      # @return Boolean
      #   if true then match on `name` exactly
      attr_accessor :name_exact

      # @return Boolean
      #   true - has name
      #   false - has no name
      #   nil - both
      attr_accessor :with_name

      # @param otu_id [Integer, Array]
      # @return Array
      #   one or more Otu ids
      attr_accessor :otu_id

      # @param taxon_name_id [Integer, Array]
      # @return Array
      #   one or more Otu taxon_name_id
      attr_accessor :taxon_name_id

      # @return Boolean
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

      # @param wkt [String]
      #  A Spatial area in WKT format
      attr_accessor :wkt

      # @return [Hash, nil]
      #  in geo_json format (no Feature ...) ?!
      attr_accessor :geo_json

      # @param geographic_area_id [String, Array]
      # @return [Array]
      attr_accessor :geographic_area_id

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
      #   true - Otu has common names
      #   false - Otu without common names
      #   nil - not applied
      attr_accessor :common_names

      # @return [True, False, nil]
      #   true - Otu has Content
      #   false - Otu without Content
      #   nil - not applied
      attr_accessor :contents

      # @return [True, False, nil]
      #   true - Otu has CollectionObjects
      #   false - Otu without CollectionObjects
      #   nil - not applied
      attr_accessor :collection_objects

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

      # Integer in Meters
      #   !! defaults to 100m
      attr_accessor :radius

      def initialize(query_params)
        super

        @ancestrify = boolean_param(params, :ancestrify)
        @asserted_distributions = boolean_param(params, :asserted_distributions)
        @biological_association_id = params[:biological_association_id]
        @biological_associations = boolean_param(params, :biological_associations)
        @collecting_event_id = params[:collecting_event_id]
        @collection_objects = boolean_param(params, :collection_objects)
        @common_names = boolean_param(params, :common_names)
        @contents = boolean_param(params, :contents)
        @coordinatify = boolean_param(params, :coordinatify)
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
        @radius = params[:radius].presence || 100.0
        @taxon_name = boolean_param(params, :taxon_name)
        @taxon_name_id = params[:taxon_name_id]
        @with_name = boolean_param(params, :with_name)
        @wkt = params[:wkt]

        set_confidences_params(params)
        set_notes_params(params)
        set_citations_params(params)
        set_depiction_params(params)
        set_data_attributes_params(params)
        set_tags_params(params)
        set_gazetteer_params(params)
      end

      def biological_associations_table
        ::BiologicalAssociation.arel_table
      end

      def descriptor_id
        [@descriptor_id].flatten.compact
      end

      def name
        [@name].flatten.compact.collect { |n| n.strip }
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

      def name_facet
        return nil if name.empty?
        if name_exact
          table[:name].in(name)
        else
          table[:name].matches_any(name.collect { |n| '%' + n.gsub(/\s+/, '%') + '%' })
        end
      end

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        if descendants
          h = Arel::Table.new(:taxon_name_hierarchies)
          j = table.join(h, Arel::Nodes::InnerJoin).on(table[:taxon_name_id].eq(h[:descendant_id]))
          z = h[:ancestor_id].in(taxon_name_id)

          ::Otu.joins(j.join_sources).where(z).distinct # Maybe not needed
        else
          ::Otu.where(taxon_name_id:)
        end
      end

      def wkt_facet
        return nil if wkt.nil?
        from_wkt(wkt)
      end

      def from_wkt(wkt_shape)
        c = ::Queries::CollectingEvent::Filter.new(wkt: wkt_shape, project_id:)
        a = ::Queries::AssertedDistribution::Filter.new(wkt: wkt_shape, project_id:)

        q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all, project_id:)
        q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all, project_id:)

        referenced_klass_union([q1, q2]).distinct # Not needed, union should be distinct
      end

      def geo_json_facet
        return nil if geo_json.blank?

        c = ::Queries::CollectingEvent::Filter.new(geo_json:, project_id:, radius:)
        a = ::Queries::AssertedDistribution::Filter.new(geo_json:, project_id:, radius:)

        q1 = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: c.all, project_id:)
        q2 = ::Otu.joins(:asserted_distributions).where(asserted_distributions: a.all, project_id:)

        referenced_klass_union([q1, q2]).distinct
      end

      def asserted_distributions_facet
        return nil if asserted_distributions.nil?
        if asserted_distributions
          ::Otu.joins(:asserted_distributions).distinct
        else
          ::Otu.where.missing(:asserted_distributions)
        end
      end

      def with_name_facet
        return nil if with_name.nil?
        if with_name
          ::Otu.where.not(name: nil)
        else
          ::Otu.where(name: nil)
        end
      end

      def contents_facet
        return nil if contents.nil?
        if contents
          ::Otu.joins(:contents).distinct
        else
          ::Otu.where.missing(:contents)
        end
      end

      def common_names_facet
        return nil if @common_names.nil?

        if @common_names
          ::Otu.joins(:common_names).distinct
        else
          ::Otu.where.missing(:common_names)
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
          ::Otu.where('NOT EXISTS (' + ::Otu.select('1').from( # not exists ( a select(1) from <opposite query>  )
                                                              ::Otu.from(
                                                                "((#{a.to_sql}) UNION (#{b.to_sql})) as ba_otus_join"
                                                              ).where('otus.id = ba_otus_join.id')
                                                             ).to_sql + ')')  # where includes in/out link
        end
      end

      def collection_objects_facet
        return nil if collection_objects.nil?
        if collection_objects
          ::Otu.joins(:collection_objects).distinct
        else
          ::Otu.where.missing(:collection_objects)
        end
      end

      def taxon_name_facet
        return nil if taxon_name.nil?

        if taxon_name
          table[:taxon_name_id].not_eq(nil)
        else
          table[:taxon_name_id].eq(nil)
        end
      end

      def observations_facet
        return nil if observations.nil?

        if observations
          ::Otu.joins(:observations).distinct
        else
          ::Otu.where.missing(:observations)
        end
      end

      def collecting_event_id_facet
        return nil if collecting_event_id.empty?
        if historical_determinations.nil?
          ::Otu.joins(:collection_objects).where(collection_objects: { collecting_event_id: }, taxon_determinations: { position: 1 }).distinct
        elsif historical_determinations
          ::Otu.joins(:collection_objects).where(collection_objects: { collecting_event_id: }).where.not(taxon_determinations: { position: 1 }).distinct
        else
          ::Otu.joins(:collection_objects).where(collection_objects: { collecting_event_id: })
        end
      end

      def biological_association_id_facet
        return nil if biological_association_id.empty?

        q1 = ::Otu.joins(:biological_associations).where(biological_associations: { id: biological_association_id, biological_association_subject_type: 'Otu' })
        q2 = ::Otu.joins(:related_biological_associations).where(related_biological_associations: { id: biological_association_id, biological_association_object_type: 'Otu' })
        q3 = ::Otu.joins(collection_objects: [:biological_associations]).where(biological_associations: { id: biological_association_id, biological_association_subject_type: 'CollectionObject' })
        q4 = ::Otu.joins(collection_objects: [:related_biological_associations]).where(related_biological_associations: { id: biological_association_id, biological_association_object_type: 'CollectionObject' })

        if historical_determinations.nil?
          q3 = q3.where(taxon_determinations: { position: 1 })
          q4 = q4.where(taxon_determinations: { position: 1 })
        elsif historical_determinations
          q3 = q3.where.not(taxon_determinations: { position: 1 })
          q4 = q4.where.not(taxon_determinations: { position: 1 })
        end

        query = referenced_klass_union([q1, q2, q3, q4])

        ::Otu.from("(#{query.to_sql}) as otus").distinct
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
          b = ::Otu.joins(:asserted_distributions).where(asserted_distributions: { asserted_distribution_shape: a })
          c = ::Otu.joins(collection_objects: [:collecting_event]).where(collecting_events: { geographic_area: a })
        when true # spatial
          i = ::GeographicItem.joins(:geographic_areas).where(geographic_areas: a) # .unscope
          wkt_shape =
            ::Queries::GeographicItem.st_union(i)
              .to_a.first['st_union'].to_s # todo, check
          return from_wkt(wkt_shape)
        end

        referenced_klass_union([b, c])
      end

      def descriptor_id_facet
        return nil if descriptor_id.empty?

        q1 = ::Otu.joins(:descriptors).where(descriptors: { id: descriptor_id })
        q2 = ::Otu.joins(collection_objects: [:descriptors]).where(descriptors: { id: descriptor_id })

        referenced_klass_union([q1, q2]).distinct
      end

      def asserted_distribution_query_facet
        return nil if asserted_distribution_query.nil?
        s = 'WITH query_ad_otus AS (' + asserted_distribution_query.all.to_sql + ') ' +
          ::Otu
          .joins('JOIN query_ad_otus as query_ad_otus1 on otus.id = query_ad_otus1.otu_id')
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def content_query_facet
        return nil if content_query.nil?
        s = 'WITH query_con_otus AS (' + content_query.all.to_sql + ') ' +
          ::Otu
          .joins('JOIN query_con_otus as query_con_otus1 on otus.id = query_con_otus1.otu_id')
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def biological_association_query_facet
        return nil if biological_association_query.nil?
        s = 'WITH query_ba_otu AS (' + biological_association_query.all.to_sql + ') '

        a = ::Otu
          .joins("JOIN query_ba_otu as query_ba_otu1 on otus.id = query_ba_otu1.biological_association_subject_id AND query_ba_otu1.biological_association_subject_type = 'Otu'")

        b = ::Otu
          .joins("JOIN query_ba_otu as query_ba_otu2 on otus.id = query_ba_otu2.biological_association_object_id AND query_ba_otu2.biological_association_object_type = 'Otu'")

        s << referenced_klass_union([a, b]).to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_otus AS (' + collection_object_query.all.to_sql + ') ' +
          ::Otu
          .joins(:collection_objects)
          .joins('JOIN query_co_otus as query_co_otus1 on collection_objects.id = query_co_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def field_occurrence_query_facet
        return nil if field_occurrence_query.nil?
        s = 'WITH query_fo_otus AS (' + field_occurrence_query.all.to_sql + ') ' +
          ::Otu
          .joins(:field_occurrences)
          .joins('JOIN query_fo_otus as query_fo_otus1 on field_occurrences.id = query_fo_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def collecting_event_query_facet
        return nil if collecting_event_query.nil?
        s = 'WITH query_ce_otus AS (' + collecting_event_query.all.to_sql + ') ' +
          ::Otu
          .joins(:collecting_events)
          .joins('JOIN query_ce_otus as query_ce_otus1 on collecting_events.id = query_ce_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def extract_query_facet
        return nil if extract_query.nil?
        s = 'WITH query_ex_otus AS (' + extract_query.all.to_sql + ') ' +
          ::Otu
          .joins(:origin_relationships)
          .joins("JOIN query_ex_otus as query_ex_otus1 on origin_relationships.new_object_id = query_ex_otus1.id and origin_relationships.new_object_type = 'Extract'")
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def taxon_name_query_facet
        return nil if taxon_name_query.nil?
        s = 'WITH query_taxon_names AS (' + taxon_name_query.all.to_sql + ') ' +
          ::Otu
          .joins('JOIN query_taxon_names as query_taxon_names1 on otus.taxon_name_id = query_taxon_names1.id')
          .where.not(taxon_name_id: nil) # .joins(:taxon_name)
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def descriptor_query_facet
        return nil if descriptor_query.nil?
        s = 'WITH query_de_otus AS (' + descriptor_query.all.to_sql + ') ' +
          ::Otu
          .joins(:observations)
          .joins('JOIN query_de_otus as query_de_otus1 on observations.descriptor_id = query_de_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def loan_query_facet
        return nil if loan_query.nil?
        s = 'WITH query_loan_otus AS (' + loan_query.all.to_sql + ') '

        a = ::Otu.joins(:loan_items)
          .joins('JOIN query_loan_otus as query_loan_otus1 on loan_items.loan_id = query_loan_otus1.id')

        b = ::Otu.joins(collection_objects: [:loan_items])
          .joins('JOIN query_loan_otus as query_loan_otus1 on loan_items.loan_id = query_loan_otus1.id')

        s << referenced_klass_union([a, b]).to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      def observation_query_facet
        return nil if observation_query.nil?
        s = 'WITH query_obs_otus AS (' + observation_query.all.to_sql + ') ' +
          ::Otu
          .joins(:observations)
          .joins('JOIN query_obs_otus as query_obs_otus1 on observations.id = query_obs_otus1.id')
          .to_sql

        ::Otu.from('(' + s + ') as otus').distinct
      end

      # !! This is a soft-link (i.e. no otu_id FK directly), so latency between indexing has a very small proability
      # !! of impacting the results.
      def dwc_occurrence_query_facet
        return nil if dwc_occurrence_query.nil?

        a = dwc_occurrence_query.all.object_join('CollectionObject').select(dwc_occurrences: [:dwc_occurrence_object_id])
        b = dwc_occurrence_query.all.object_join('AssertedDistribution').select(dwc_occurrences: [:dwc_occurrence_object_id])
        c = dwc_occurrence_query.all.object_join('FieldOccurrence').select(dwc_occurrences: [:dwc_occurrence_object_id])

        d = ::Otu.with(co: a)
              .joins(:taxon_determinations).where(taxon_determinations: {position: 1})
              .joins('JOIN co on co.dwc_occurrence_object_id = taxon_determinations.taxon_determination_object_id')

        e = ::Otu.with(ad: b)
              .joins(:asserted_distributions)
              .joins('JOIN ad on ad.dwc_occurrence_object_id = asserted_distributions.id')

        f = ::Otu.with(fo: c)
              .joins(:taxon_determinations).where(taxon_determinations: {position: 1})
              .joins('JOIN fo on fo.dwc_occurrence_object_id = taxon_determinations.taxon_determination_object_id')

        ::Queries.union(::Otu, [d,e,f])
      end

      # Expands result of OTU filter query in 2 ways:
      #  1 - to include all valid OTUs by (proxy of TaxonName) if OTU is by proxy invalid
      #  2 - to include all invalid OTUS (by proxy of TaxonName) if OTU is by proxy valid
      #
      # In essence this creates full sets of TaxonConcepts from partial results.
      # The result can be used to, for example, get a comprehensive list of Sources for the concept,
      # or a comprehensive historical list of Specimens, etc.
      def coordinatify_result(q)

        i = q.joins(:taxon_name).where('taxon_names.id != taxon_names.cached_valid_taxon_name_id').where(project_id:)
        v = q.joins(:taxon_name).where('taxon_names.id = taxon_names.cached_valid_taxon_name_id').where(project_id:)

        # Find valid for invalid
        s = 'WITH invalid_otu_result AS (' + i.to_sql + ') ' +
          ::Otu
          .joins('JOIN taxon_names tn1 on otus.taxon_name_id = tn1.cached_valid_taxon_name_id')
          .joins('JOIN invalid_otu_result AS invalid_otu_result1 ON invalid_otu_result1.taxon_name_id = tn1.id') # invalid otus matching valid names
          .to_sql

        a = ::Otu.from('(' + s + ') as otus')

        # Find invalid for valid
        t = 'WITH valid_otu_result AS (' + v.to_sql + ') ' +
          ::Otu
          .joins('JOIN taxon_names tn2 on otus.taxon_name_id = tn2.id')
          .joins('JOIN valid_otu_result AS valid_otu_result1 ON valid_otu_result1.taxon_name_id = tn2.cached_valid_taxon_name_id') # valid otus matching invalid names
          .to_sql

        b = ::Otu.from('(' + t + ') as otus')

        referenced_klass_union([a, b, q]).distinct # Unions shouldn't need distinct
      end

      def ancestrify_result(q)
        a = q

        s = 'WITH otu_base AS (' + a.all.to_sql + ') ' +
          ::Otu
          .joins('JOIN taxon_name_hierarchies tnh on tnh.ancestor_id = otus.taxon_name_id')
          .joins('JOIN otu_base as otu_base1 on otu_base1.taxon_name_id = tnh.descendant_id')
          .to_sql

        b = ::Otu.from('(' + s + ') as otus')

        referenced_klass_union([a, b])
      end

      def and_clauses
        [
          name_facet,
          taxon_name_facet,
        ]
      end

      def merge_clauses
        [
          asserted_distribution_query_facet,
          asserted_distributions_facet,
          biological_association_query_facet,
          collecting_event_query_facet,
          collection_object_query_facet,
          dwc_occurrence_query_facet,
          field_occurrence_query_facet,
          content_query_facet,
          descriptor_query_facet,
          extract_query_facet,
          loan_query_facet,
          observation_query_facet,
          taxon_name_query_facet,

          biological_association_id_facet,
          biological_associations_facet,
          collecting_event_id_facet,
          collection_objects_facet,
          common_names_facet,
          contents_facet,
          descriptor_id_facet,
          geo_json_facet,
          gazetteer_id_facet,
          geographic_area_id_facet,
          observations_facet,
          taxon_name_id_facet,
          with_name_facet,
          wkt_facet,
        ].compact
      end

      # @return [ActiveRecord::Relation]
      def all(nil_empty = false)
        q = super

        # Order matters, coordinatify should be last as its "out"
        q = ancestrify_result(q) if ancestrify
        q = coordinatify_result(q) if coordinatify

        q
      end
    end
  end
end
