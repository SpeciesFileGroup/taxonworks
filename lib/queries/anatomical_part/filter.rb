module Queries
  module AnatomicalPart
    class Filter < Query::Filter
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations
      include Queries::Concerns::PreparationTypes

      PARAMS = [
        :anatomical_part_id,
        :is_material,
        :name,
        :name_exact,
        :origin_object_type,
        :otu_id,
        :uri,

        anatomical_part_id: [],
        origin_object_type: [],
        otu_id: []
      ].freeze

      # @return [Array]
      attr_accessor :anatomical_part_id

      # @return [Boolean, nil]
      attr_accessor :is_material

      # @return String
      attr_accessor :name

      # @return [Boolean, nil]
      attr_accessor :name_exact

      # @return [Array]
      attr_accessor :origin_object_type

      # @return [Array]
      # OTU id of the ancestor origin OTU or CO/FO taxon determination.
      attr_accessor :otu_id

      # @return String
      attr_accessor :uri

      # @param params [Hash]
      def initialize(query_params)
        super

        @anatomical_part_id = params[:anatomical_part_id]
        @is_material = boolean_param(params, :is_material)
        @name = params[:name]
        @name_exact = boolean_param(params, :name_exact)
        @origin_object_type = params[:origin_object_type]
        @otu_id = params[:otu_id]
        @uri = params[:uri]
        set_citations_params(params)
        set_tags_params(params)
        set_preparation_types_params(params)
      end

      def anatomical_part_id
        [@anatomical_part_id].flatten.compact
      end

      def origin_object_type
        [@origin_object_type].flatten.compact
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def name_facet
        return nil if name.blank?
        if name_exact
          table[:name].eq(name.strip)
        else
          table[:name].matches('%' + name.strip.gsub(/\s/, '%') + '%')
        end
      end

      def uri_facet
        return nil if uri.blank?

        table[:uri].eq(uri)
      end

      def is_material_facet
        return nil if is_material.nil?

        if is_material === false
          table[:is_material].eq(is_material)
        else
          table[:is_material].eq(true).or(table[:is_material].eq(nil))
        end
      end

      def origin_object_type_facet
        return nil if origin_object_type.empty?

        ::AnatomicalPart
          .joins(:related_origin_relationships)
          .where(related_origin_relationships: { old_object_type: origin_object_type })
          .distinct # remove if model adds validations to make this unnecessary
      end

      def otu_id_facet
        return nil if otu_id.empty?

        table[:cached_otu_id].in(otu_id)
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?

        ::AnatomicalPart
          .joins(:related_origin_relationships)
          .where("origin_relationships.old_object_id IN (#{collection_object_query.all.select(:id).to_sql })")
      end

      def field_occurrence_query_facet
        return nil if field_occurrence_query.nil?

        ::AnatomicalPart
          .joins(:related_origin_relationships)
          .where("origin_relationships.old_object_id IN (#{collection_object_query.all.select(:id).to_sql })")
      end

      def otu_query_facet
        return nil if otu_query.nil?

        ::AnatomicalPart
          .joins(:related_origin_relationships)
          .where("origin_relationships.old_object_id IN (#{otu_query.all.select(:id).to_sql })")
      end

      def observation_query_facet
        return nil if observation_query.nil?

        ::AnatomicalPart
          .joins(:related_origin_relationships)
          .where("origin_relationships.old_object_id IN (#{observation_query.all.select(:id).to_sql })")
      end

      def extract_query_facet
        return nil if extract_query.nil?

        ::AnatomicalPart
          .joins(:origin_relationships)
          .where("origin_relationships.new_object_id IN (#{extract_query.all.select(:id).to_sql })")
      end

      def sound_query_facet
        return nil if sound_query.nil?

        ::AnatomicalPart
          .joins(:origin_relationships)
          .where("origin_relationships.new_object_id IN (#{sound_query.all.select(:id).to_sql })")
      end


      def and_clauses
        [
          is_material_facet,
          name_facet,
          uri_facet,
          otu_id_facet
        ]
      end

      def merge_clauses
        [
          collection_object_query_facet,
          extract_query_facet,
          field_occurrence_query_facet,
          otu_query_facet,
          observation_query_facet,
          sound_query_facet,

          origin_object_type_facet
        ]
      end

    end
  end
end
