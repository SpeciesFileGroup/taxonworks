module Queries
  module BiocurationClassification

    class Filter < Query::Filter
      include Queries::Helpers

      PARAMS = [
        :biocuration_classification_id,
        :biocuration_class_id, 
        :biocuration_classification_object_id, 
        :biocuration_classification_object_type,
        biocuration_classification_id: [],
        biocuration_class_id: [],
        biocuration_classification_object_id: [],
        biocuration_classification_object_type: []
      ].freeze

      # @return Array, Integer
      attr_accessor :biocuration_classification_id

      # Array, Integer
      attr_accessor :biocuration_class_id

      # Array, Integer
      attr_accessor :biocuration_classification_object_id

      # Array, Integer
      attr_accessor :biocuration_classification_object_type

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super

        @biocuration_classification_id = params[:biocuration_classification_id]
        @biocuration_class_id = params[:biocuration_class_id]
        @biocuration_classification_object_type = params[:biocuration_classification_object_type]
        @biocuration_classification_object_id = params[:biocuration_classification_object_id]
      end

      def biocuration_classification_id
        [@biocuration_classification_id].flatten.compact.uniq
      end

      def biocuration_class_id
        [@biocuration_class_id].flatten.compact.uniq
      end

      def biocuration_classification_object_type
        [@biocuration_classification_object_type].flatten.compact
      end

      def biocuration_classification_object_id
        [@biocuration_classification_object_id].flatten.compact
      end

      def biocuration_class_id_facet
        biocuration_class_id.empty? ? nil : table[:biocuration_class_id].in(biocuration_class_id)
      end

      def object_id_facet
        biocuration_classification_object_id.empty? ? nil : table[:biocuration_classification_object_id].in(biocuration_classification_object_id)
      end

      def object_type_facet
        biocuration_classification_object_type.empty? ? nil : table[:biocuration_classification_object_type].in(biocuration_classification_object_type)
      end

      def and_clauses
        [
          biocuration_class_id_facet,
          object_id_facet,
          object_type_facet,
        ]
      end

    end
  end
end
