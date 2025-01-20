module Queries
  module Conveyance
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Conveyance)

      PARAMS = [
        *::Conveyance.related_foreign_keys.map(&:to_sym),
        :conveyance_id,
        :name,
        :conveyance_object_type,
        :conveyance_object_id,
        conveyance_id: [],
        conveyance_object_id: [],
        conveyance_object_type: [],
      ].freeze

      # @return Array
      attr_accessor :conveyance_id

      # @param name [String, nil]
      #   wildcard wrapped, always, to match against `name`
      attr_accessor :name

      # @return [Array]
      # @params conveyance_object_type array or string
      attr_accessor :conveyance_object_type

      # @return [Array]
      # @params conveyance_object_id array or string (integer)
      attr_accessor :conveyance_object_id

      def initialize(query_params)
        super

        @conveyance_id = params[:conveyance_id]
        @name = params[:name]
        @conveyance_object_type = params[:conveyance_object_type]
        @conveyance_object_id = params[:conveyance_object_id]

        set_polymorphic_params(params)
      end

      def conveyance_id
        [@conveyance_id].flatten.compact
      end

      def conveyance_object_id
        [@conveyance_object_id].flatten.compact
      end

      def conveyance_object_type
        [@conveyance_object_type].flatten.compact
      end

      def name_facet
        return nil if name.blank?
        table[:name].matches('%' + name + '%')
      end

      def conveyance_object_type_facet
        return nil if conveyance_object_type.empty?
        table[:conveyance_object_type].in(conveyance_object_type)
      end

      def conveyance_object_id_facet
        return nil if conveyance_object_id.empty?
        table[:conveyance_object_id].in(conveyance_object_id)
      end

      def and_clauses
        [
          name_facet,
          conveyance_object_id_facet,
          conveyance_object_type_facet,
        ]
      end
    end
  end
end
