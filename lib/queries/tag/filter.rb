module Queries
  module Tag

    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Tag)

      PARAMS = [
        *::Tag.related_foreign_keys.map(&:to_sym),
        :keyword_id,
        :tag_object_type,
        :tag_object_id,
        keyword_id: [],
        tag_object_type: [],
        tag_object_id: [],
      ].freeze

      # @return Array
      attr_accessor :tag_id

      # Array, Integer
      attr_accessor :keyword_id

      # Array, Integer
      attr_accessor :tag_object_type

      # Array, Integer
      attr_accessor :tag_object_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super

        @tag_id = params[:tag_id]
        @keyword_id = [params[:keyword_id]]
        @tag_object_type = params[:tag_object_type]
        @tag_object_id = params[:tag_object_id]

        set_polymorphic_params(params)
      end

      def tag_id
        [@tag_id].flatten.compact.uniq
      end

      def keyword_id
        [@keyword_id].flatten.compact.uniq
      end

      def tag_object_type
        [@tag_object_type].flatten.compact
      end

      def tag_object_id
        [@tag_object_id].flatten.compact
      end

      def keyword_id_facet
        !keyword_id.empty? ? table[:keyword_id].eq_any(keyword_id)  : nil
      end

      def object_id_facet
        tag_object_id.empty? ? nil : table[:tag_object_id].eq_any(tag_object_id)
      end

      def tag_object_type_facet
        tag_object_type.empty? ? nil : table[:tag_object_type].eq_any(tag_object_type)
      end

      def and_clauses
        [
          keyword_id_facet,
          object_id_facet,
          tag_object_type_facet,
        ]
      end

    end
  end
end
