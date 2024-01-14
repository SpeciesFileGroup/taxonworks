module Queries
  module ProtocolRelationship
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::ProtocolRelationship)

      PARAMS = [
        *::ProtocolRelationship.related_foreign_keys.map(&:to_sym),
        :protocol_id,
        :protocol_relationship_id,

        :protocol_relationship_object_id,
        :protocol_relationship_object_type,
        protocol_relationship_id: [],
        protocol_relationship_object_id: [],
        protocol_id: []
      ].freeze

      # @param [Array, Integer]
      # @return Array
      attr_accessor :protocol_relationship_id

      # @param [Array, Integer]
      # @return Array
      attr_accessor :protocol_id

      # @param [Array, integer]
      # @return Array
      attr_accessor :protocol_relationship_object_id

      # @return String, nil
      attr_accessor :protocol_relationship_object_type

      # TODO: See ::Queries::Annotator params - move to permitted section in controller likely.
      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @protocol_relationship_object_id = params[:protocol_relationship_object_id]
        @protocol_relationship_object_type = params[:protocol_relationship_object_type]
        @protocol_id = params[:protocol_id]
        @protocol_relationhip_id = params[:protocol_relationship_id]
        set_polymorphic_params(params)
      end

      def protocol_relationship_id
        [@protocol_relationship_id].flatten.compact
      end

      def protocol_id
        [@protocol_id].flatten.compact
      end

      def protocol_relationship_object_id
        [@protocol_relationship_object_id].flatten.compact
      end

      def protocol_relationship_object_type
        [@protocol_relationship_object_type].flatten.compact
      end

      def protocol_id_facet
        return nil if protocol_id.empty?
        table[:protocol_id].in(protocol_id)
      end

      def protocol_relationship_object_id_facet
        return nil if protocol_relationship_object_id.empty?
        table[:protocol_relationship_object_id].in(protocol_relationship_object_id)
      end

      def protocol_relationship_object_type_facet
        return nil if protocol_relationship_object_type.empty?
        table[:protocol_relationship_object_type].in(protocol_relationship_object_type)
      end

      def and_clauses
        [
         protocol_id_facet,
         protocol_relationship_object_id_facet,
         protocol_relationship_object_type_facet,
       ]
      end
    end
  end
end
