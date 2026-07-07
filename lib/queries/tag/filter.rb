module Queries
  module Tag

    class Filter < Query::Filter

      include Concerns::Polymorphic
      include Queries::Concerns::Sortable
      polymorphic_klass(::Tag)

      def self.sortable_columns
        {
          'id'              => sort_by_direct_column('tags.id'),
          'tag_object_type' => sort_by_direct_column('tags.tag_object_type'),
          'created_at'      => sort_by_direct_column('tags.created_at'),
          'updated_at'      => sort_by_direct_column('tags.updated_at'),
          'created_by'      => sort_by_direct_column('tags.created_by_id'),
          'keyword.object_tag' => sort_by_belongs_to_column(
            joined_table: 'controlled_vocabulary_terms',
            joined_column: 'name',
            fk_expr: 'tags.keyword_id',
            alias_prefix: 'sort_tag_keyword'
          )
        }
      end

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
        !keyword_id.empty? ? table[:keyword_id].in(keyword_id)  : nil
      end

      def object_id_facet
        tag_object_id.empty? ? nil : table[:tag_object_id].in(tag_object_id)
      end

      def tag_object_type_facet
        tag_object_type.empty? ? nil : table[:tag_object_type].in(tag_object_type)
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
