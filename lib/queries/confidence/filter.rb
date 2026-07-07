module Queries
  module Confidence
    class Filter < Query::Filter
      include Concerns::Polymorphic
      include Queries::Concerns::Sortable
      polymorphic_klass(::Confidence)

      def self.sortable_columns
        {
          'id'                     => sort_by_direct_column('confidences.id'),
          'confidence_object_type' => sort_by_direct_column('confidences.confidence_object_type'),
          'created_at'             => sort_by_direct_column('confidences.created_at'),
          'updated_at'             => sort_by_direct_column('confidences.updated_at'),
          'created_by'             => sort_by_direct_column('confidences.created_by_id'),
          'confidence_level.object_tag' => sort_by_belongs_to_column(
            joined_table: 'controlled_vocabulary_terms',
            joined_column: 'name',
            fk_expr: 'confidences.confidence_level_id',
            alias_prefix: 'sort_confidence_level'
          )
        }
      end

      PARAMS = [
        *::Confidence.related_foreign_keys.map(&:to_sym),
        :confidence_id,
        :confidence_level_id,
        :confidence_object_id,
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
        confidence_level_id.present? ? table[:confidence_level_id].in(confidence_level_id)  : nil
      end

      # @return [Arel::Node, nil]
      def confidence_object_type_facet
        confidence_object_type.present? ? table[:confidence_object_type].in(confidence_object_type)  : nil
      end

      # @return [Arel::Node, nil]
      def confidence_object_id_facet
        confidence_object_id.empty? ? nil : table[:confidence_object_id].in(confidence_object_id)
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
