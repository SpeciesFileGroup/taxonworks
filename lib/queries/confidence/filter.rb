module Queries
  module Confidence

    class Filter < Query::Filter
      # Params specific to Confidence

      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here

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

      # Array, Integer
      attr_accessor :confidence_id

      # Array, Integer
      attr_accessor :confidence_level_id

      # Array, Integer
      attr_accessor :confidence_object_type

      # Array, Integer
      attr_accessor :confidence_object_id

      # attr_accessor :options

      # Array, Integer
      # attr_accessor :object_global_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @confidence_id = params[:confidence_id]
        @confidence_level_id = [params[:confidence_level_id]].flatten.compact
        @confidence_object_type = params[:confidence_object_type]
        @confidence_object_id = params[:confidence_object_id]
        @object_global_id = params[:object_global_id]
        #@options = params

        set_polymorphic_ids(params)
      end

      def confidence_id
        [@confidence_id].flatten.compact.uniq
      end

      def confidence_object_type
        [@confidence_object_type, global_object_type].flatten.compact
      end

      def confidence_object_id
        [@confidence_object_id, global_object_id].flatten.compact
      end

      # TODO - rename _facet

      # @return [Arel::Node, nil]
      def matching_confidence_level_id
        !confidence_level_id.blank? ? table[:confidence_level_id].eq_any(confidence_level_id)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_confidence_object_type
        !confidence_object_type.blank? ? table[:confidence_object_type].eq(confidence_object_type)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_confidence_object_id
        confidence_object_id.empty? ? nil : table[:confidence_object_id].eq_any(confidence_object_id)
      end

      def and_clauses
        [
          matching_confidence_level_id,
          matching_confidence_object_id,
          matching_confidence_object_type,
          matching_polymorphic_ids,
        ]
      end

    end
  end
end
