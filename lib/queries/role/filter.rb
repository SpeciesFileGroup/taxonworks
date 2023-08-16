module Queries
  module Role

    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Role)

      # !!! Params are still pre-filtered in roles controller, that needs to be removed.
      PARAMS = [
        *::Role.related_foreign_keys.map(&:to_sym),
        :role_id,
        :role_object_id,
        :role_object_type,
        :role_type,
        role_id: [],
        role_object_id: [],
        role_object_type: [],
        role_type: [],
      ].freeze

      # @return Array
      attr_accessor :role_id

      # @param role [Array, String]
      #   A valid role name like 'Author' or array like ['TaxonDeterminer', 'SourceEditor'].  See Role descendants.
      # @return [Array]
      attr_accessor :role_type

      # Array, Integer
      attr_accessor :role_object_type

      attr_accessor :role_object_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @role_type = params[:role_type]
        @role_id = params[:role_id]

        @role_object_id = params[:role_object_id]
        @role_object_type = params[:role_object_type]

        set_polymorphic_params(params)
      end

      def role_id
        [@role_id].flatten.compact
      end

      def role_type
        [@role_type].flatten.compact
      end

      def role_object_type
        [@role_object_type].flatten.compact
      end

      def role_object_id
        [@role_object_id].flatten.compact
      end

      def role_type_facet
        return nil if role_type.empty?
        table[:type].eq_any(role_type)
      end

      def role_object_type_facet
        return nil if role_object_type.empty?
        table[:role_object_type].eq_any(role_object_type)
      end

      def role_object_id_facet
        return nil if role_object_id.empty?
        table[:role_object_id].eq_any(role_object_id)
      end

      def and_clauses
        [ role_type_facet,
          role_object_type_facet,
          role_object_id_facet,
      ]
      end

    end
  end
end
