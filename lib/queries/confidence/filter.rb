module Queries
  module Confidence
    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Confidence)

      PARAMS = [
        :confidence_id,
        :confidence_level_id,
        :confidence_object_type,
        confidence_id: [],
        confidence_level_id: [],
        confidence_object_type: [],
      ].freeze

      # @return Array
      attr_accessor :confidence_id

      # @return Array
      attr_accessor :confidence_level_id

      # @return Array
      attr_accessor :confidence_object_type

      # @return Array
      attr_accessor :confidence_object_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @confidence_id = params[:confidence_id]
        @confidence_level_id = [params[:confidence_level_id]].flatten.compact
        @confidence_object_type = params[:confidence_object_type]
        @confidence_object_id = params[:confidence_object_id]

        set_polymorphic_params(params)
      end

      def confidence_id
        [@confidence_id].flatten.compact.uniq
      end

      def confidence_object_type
        [@confidence_object_type].flatten.compact
      end

      def confidence_object_id
        [@confidence_object_id].flatten.compact
      end

      # @return [Arel::Node, nil]
      def confidence_level_id_facet
        !confidence_level_id.blank? ? table[:confidence_level_id].eq_any(confidence_level_id)  : nil
      end

      # @return [Arel::Node, nil]
      def confidence_object_type_facet
        !confidence_object_type.blank? ? table[:confidence_object_type].eq(confidence_object_type)  : nil
      end

      # @return [Arel::Node, nil]
      def confidence_object_id_facet
        confidence_object_id.empty? ? nil : table[:confidence_object_id].eq_any(confidence_object_id)
      end

      def and_clauses
        [
          confidence_level_id_facet,
          confidence_object_id_facet,
          confidence_object_type_facet,
        ]
      end

    end
  end
end
