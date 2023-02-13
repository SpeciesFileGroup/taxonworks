module Queries
  module Role

    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Role)

      PARAMS = [
        *::Role.related_foreign_keys.map(&:to_sym),
        :role_id,
        :role_type,
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
        @role_id = params[:role_id]

        set_polymorphic_params(params)
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

      def and_clauses
        [ role_type_facet ]
      end

    end
  end
end
