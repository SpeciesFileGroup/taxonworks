module Queries
  module Documentation
    class Filter < Query::Filter

      include Concerns::Polymorphic
      include Queries::Concerns::Sortable
      polymorphic_klass(::Documentation)

      def self.sortable_columns
        {
          'id'                        => sort_by_direct_column('documentation.id'),
          'documentation_object_type' => sort_by_direct_column('documentation.documentation_object_type'),
          'created_at'                => sort_by_direct_column('documentation.created_at'),
          'updated_at'                => sort_by_direct_column('documentation.updated_at'),
          'created_by'                => sort_by_direct_column('documentation.created_by_id'),
          'document.object_tag'       => sort_by_belongs_to_column(
            joined_table: 'documents',
            joined_column: 'document_file_file_name',
            fk_expr: 'documentation.document_id',
            alias_prefix: 'sort_documentation_doc'
          )
        }
      end

      PARAMS = [
        *::Documentation.related_foreign_keys.map(&:to_sym), 
        :documentation_id,
        :documentation_object_id,
        :documentation_object_type,
        documentation_id: [],
      ].freeze

      attr_accessor :documentation_id

      attr_accessor :documentation_object_id

      attr_accessor :documentation_object_type

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @documentation_id = params[:documentation_id]
        @documentation_object_id = params[:documentation_object_id]
        @documentation_object_type = params[:documentation_object_type]

        set_polymorphic_params(params)
      end

      def documentation_id
        [@documentation_id].flatten.compact
      end

      def documentation_object_type
        [@documentation_object_type].flatten.compact
      end

      def documentation_object_id
        [@documentation_object_id].flatten.compact
      end

      def documentation_object_type_facet
        return nil if documentation_object_type.empty?
        table[:documentation_object_type].in(documentation_object_type)
      end

      def documentation_object_id_facet
        return nil if documentation_object_id.empty?
        table[:documentation_object_id].in(documentation_object_id)
      end

      # If we add merge_clauses then we likely have
      # to deal with excluding the `xml` field from distinct+intersection calls
      # via a custom base_query field.

      def and_clauses
        [
          documentation_object_id_facet,
          documentation_object_type_facet
        ]
      end

    end
  end
end