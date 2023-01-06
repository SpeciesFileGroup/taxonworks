module Queries
  module ProtocolRelationship
    class Filter < Query::Filter

      # TODO: revisit for permitted params
      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # @param [Array, Integer]
      # @return Array
      attr_accessor :protocol_id

      # @param [Array, integer]
      # @return Array
      attr_accessor :protocol_relationship_object_id

      # @return String, nil
      attr_accessor :protocol_relationship_object_type

      # TODO: object_global_id

      # TODO: See ::Queries::Annotator params - move to permitted section in controller likely.
      # @params params [ActionController::Parameters]
      def initialize(params)
        @options = params
        @protocol_relationship_object_id = params[:protocol_relationship_object_id]
        @protocol_relationship_object_type = params[:protocol_relationship_object_type]
        @protocol_id = params[:protocol_id]
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
        table[:protocol_id].eq_any(protocol_id)
      end

      def protocol_relationship_object_id_facet
        return nil if protocol_relationship_object_id.empty?
        table[:protocol_relationship_object_id].eq_any(protocol_relationship_object_id)
      end

      def protocol_relationship_object_type_facet
        return nil if protocol_relationship_object_type.empty?
        table[:protocol_relationship_object_type].eq_any(protocol_relationship_object_type)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          protocol_id_facet,
          protocol_relationship_object_id_facet,
          protocol_relationship_object_type_facet,
          ::Queries::Annotator.annotator_params(options, ::ProtocolRelationship),
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::ProtocolRelationship.where(and_clauses)
        else
          ::ProtocolRelationship.all
        end
      end

    end
  end
end
