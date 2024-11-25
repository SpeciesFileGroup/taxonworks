module Queries
  module Depiction
    class Filter < Query::Filter
      include Queries::Concerns::Tags

      # We can't use distinct in SQL on XML column types, 
      # this may come back to bite us if we try to use
      # distinct Depictions + overlays
      DISTINCT_ATTRIBUTES = (::Depiction.column_names - ['svg_clip']).map(&:to_sym).freeze

      PARAMS = [
        :depiction_id,
        :depiction_object_id,
        :depiction_object_type,
        :image_id,
        :otu_id,
        depiction_id: [],
        depiction_object_id: [],
        depiction_object_type: [],
        image_id: [],
        otu_id: [],
        otu_scope: [], # ripped from Image filter
      ].freeze

      attr_accessor :depiction_id

      attr_accessor :image_id

      attr_accessor :depiction_object_id

      attr_accessor :depiction_object_type

      attr_accessor :otu_id
      attr_accessor :otu_scope

      # We can't .distinct on xml fields
      # If you need to return the svg_clip attribute
      # then you must `all.unscope(:select).select('*')`
      def self.base_query
        ::Depiction.select(DISTINCT_ATTRIBUTES)
      end

      # @param params [Hash]
      def initialize(query_params)
        super

        @depiction_id = params[:depiction_id]
        @depiction_object_id = params[:depiction_object_id]
        @depiction_object_type = params[:depiction_object_type]
        @image_id = params[:image_id]
        @otu_id = params[:otu_id]
        @otu_scope = params[:otu_scope]

        set_tags_params(params)
      end

      def image_id
        [@image_id].flatten.compact
      end

      def depiction_id
        [@depiction_id].flatten.compact
      end

      def depiction_object_type
        [@depiction_object_type].flatten.compact
      end

      def depiction_object_id
        [@depiction_object_id].flatten.compact
      end

      def otu_id
        [ @otu_id ].flatten.compact
      end

      def otu_scope
        [ @otu_scope ].flatten.compact.map(&:to_sym)
      end

      def depiction_id_facet
        return nil if depiction_id.empty?
        table[:id].in(depiction_id)
      end

      def image_id_facet
        return nil if image_id.empty?
        table[:image_id].in(image_id)
      end

      def depiction_object_type_facet
        return nil if depiction_object_type.empty?
        table[:depiction_object_type].in(depiction_object_type)
      end

      def depiction_object_id_facet
        return nil if depiction_object_id.empty?
        table[:depiction_object_id].in(depiction_object_id)
      end

      def image_query_facet
        return nil if image_query.nil?
        ::Depiction.with(image_query: image_query.all )
          .joins('JOIN image_query as image_query1 on image_query1.id = depictions.image_id')
          .select(DISTINCT_ATTRIBUTES)
          .distinct
      end

      def otu_facet
        return nil if otu_id.empty? || !otu_scope.empty?
        otu_facet_otus(otu_id)
      end

      # Otu scope facet is identical in images
      # but used here to return depictions
      # specific to an OTU context

      def otu_scope_facet
        return nil if otu_id.empty? || otu_scope.empty?

        otu_ids = otu_id
        otu_ids += ::Otu.coordinate_otu_ids(otu_id) if otu_scope.include?(:coordinate_otus)
        otu_ids.uniq!

        selected = []

        if otu_scope.include?(:all)
          selected = [
            :otu_facet_otus,
            :otu_facet_collection_objects,
            :otu_facet_otu_observations,
            :otu_facet_collection_object_observations,
            :otu_facet_type_material,
            :otu_facet_type_material_observations
          ]
        elsif otu_scope.empty?
          selected = [:otu_facet_otus]
        else
          selected.push :otu_facet_otus if otu_scope.include?(:otus)
          selected.push :otu_facet_collection_objects if otu_scope.include?(:collection_objects)
          selected.push :otu_facet_collection_object_observations if otu_scope.include?(:collection_object_observations)
          selected.push :otu_facet_otu_observations if otu_scope.include?(:otu_observations)
          selected.push :otu_facet_type_material if otu_scope.include?(:type_material)
          selected.push :otu_facet_type_material_observations if otu_scope.include?(:type_material_observations)
        end

        ::Queries.union(::Depiction, selected.collect{|a| send(a, otu_ids) })
      end

      def otu_facet_type_material_observations(otu_ids)
        o = ::TypeMaterial.joins(protonym: [:otus], collection_object: [:observations])
          .where(otus: {id: otu_ids})
          .select('observations.id')

        ::Depiction.select(DISTINCT_ATTRIBUTES).with(obs: o)
          .joins("JOIN obs on depictions.depiction_object_type = 'Observation' AND depictions.depiction_object_id = obs.id")
      end

      # Find all TaxonNames, and their synonyms
      def otu_facet_type_material(otu_ids)
        # Double check that there are otu_ids,
        #  this check exists in calling methods, but re-inforce here.
        protonyms = if otu_ids.any?
                      ::Queries::TaxonName::Filter.new(
                        otu_query: { otu_id: otu_ids},
                        synonymify: true,
                        project_id:
                      ).all.where(type: 'Protonym')
                    else
                      TaxonName.none
                    end

        co = ::CollectionObject.joins(type_materials: [:protonym]).where(collection_objects: {type_materials: {protonym: protonyms}})

        ::Depiction.select(DISTINCT_ATTRIBUTES)
          .with(co_query: co)
          .joins("JOIN co_query cq on cq.id = depiction_object_id AND depiction_object_type = 'CollectionObject'")
      end

      def otu_facet_otus(otu_ids)
        ::Depiction.select(DISTINCT_ATTRIBUTES).where(depictions: {depiction_object_type: 'Otu', depiction_object_id: otu_ids})
      end

      def otu_facet_collection_objects(otu_ids)
        co = ::CollectionObject.joins(:taxon_determinations)
          .where(taxon_determinations: {otu_id: otu_ids})

        ::Depiction.select(DISTINCT_ATTRIBUTES)
          .with(co_query: co)
          .joins("JOIN co_query on co_query.id = depiction_object_id and depiction_object_type = 'CollectionObject'")
      end

      def otu_facet_collection_object_observations(otu_ids)
        co = ::CollectionObject.joins(:taxon_determinations, :observations)
          .where(taxon_determinations: {otu_id: otu_ids})
          .select('observations.id as observation_id')

        ::Depiction.select(DISTINCT_ATTRIBUTES).with(co_query: co)
          .joins("JOIN co_query on co_query.observation_id = depiction_object_id and depiction_object_type = 'Observation'")
      end

      def otu_facet_otu_observations(otu_ids)
        co = ::Otu.joins(:observations)
          .where(otus: {id: otu_ids})
          .select('observations.id as observation_id')

        ::Depiction.select(DISTINCT_ATTRIBUTES)
          .with(co_query: co)
          .joins("JOIN co_query on co_query.observation_id = depiction_object_id and depiction_object_type = 'Observation'")
      end

      def merge_clauses
        [
          image_query_facet,
          otu_facet,
          otu_scope_facet
        ].compact
      end

      def and_clauses
        [
          depiction_id_facet,
          depiction_object_id_facet,
          depiction_object_type_facet,
          image_id_facet
        ]
      end

    end
  end
end
