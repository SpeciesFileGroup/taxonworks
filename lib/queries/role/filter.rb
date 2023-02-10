module Queries
  module Role

    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Role)

      PARAMS = [
        :role_id,
        :role_type,
        :object_global_id,
        role_id: [],
        role_type: [],
      ].freeze

      # @return Array
      attr_accessor :role_id

      # @param role [Array, String]
      #   A valid role name like 'Author' or array like ['TaxonDeterminer', 'SourceEditor'].  See Role descendants.
      # @return [Array]
      attr_accessor :role_type

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @role_type = params[:role_type]
        @object_global_id = params[:object_global_id]
        @role_id = params[:role_id]

        set_polymorphic_ids(params)
      end

      def role_id
        [@role_id].flatten.compact
      end

      def role_type
        [@role_type].flatten.compact
      end

      def role_type_facet
        return nil if role_type.empty?
        table[:type].eq_any(role_type)
      end

      # TODO: DRY.  See also Notes filter
      def object_global_id_facet
        return nil if object_global_id.nil?
        o = GlobalID::Locator.locate(object_global_id)
        k = o.class.base_class.name
        id = o.id
        table[:role_object_id].eq(o.id).and(table[:role_object_type].eq(k))
      end

      def and_clauses
        [
          role_type_facet,
          object_global_id_facet
        ]
      end

      def merge_clauses
        [
          matching_polymorphic_ids
        ]
      end

    end
  end
end
