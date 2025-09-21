module Queries
  module AnatomicalPart
    class Filter < Query::Filter
      include Queries::Concerns::Tags
      include Queries::Concerns::Citations

      PARAMS = [
        :anatomical_part_id,
        :is_material,
        :name,
        :name_exact,
        :origin_object_type,
        :uri,

        anatomical_part_id: [],
        origin_object_type: [],
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
        @uri = params[:uri]
        set_citations_params(params)
        set_tags_params(params)
      end

      def anatomical_part_id
        [@anatomical_part_id].flatten.compact
      end

      def origin_object_type
        [@origin_object_type].flatten.compact
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

      def and_clauses
        [
          is_material_facet,
          name_facet,
          uri_facet
        ]
      end

      def merge_clauses
        [
          origin_object_type_facet
        ]
      end

    end
  end
end
