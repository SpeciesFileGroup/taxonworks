# To identify the polymorphic params, include the pertinent model we rereference here
require_dependency Rails.root.to_s + '/app/models/collecting_event'

module Queries
  module Citation

    # !! does not inherit from base query
    class Filter
      
      include Concerns::Polymorphic
      polymorphic_klass(::Citation)

      # Array, Integer
      attr_accessor :citation_object_type, :citation_object_id, :source_id

      # @params params [Hash]
      #   already Permitted params, or new Hash
      def initialize(params)
        @citation_object_type = params[:citation_object_type]
        @citation_object_id = params[:citation_object_id]
        @source_id = params[:source_id]
        set_polymorphic_ids(params)
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          matching_citation_object_type,
          matching_citation_object_id,
          matching_source_id,
          matching_polymorphic_ids,
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_citation_object_type
        citation_object_type.blank? ? nil : table[:citation_object_type].eq(citation_object_type) 
      end

      # @return [Arel::Node, nil]
      def matching_citation_object_id
        citation_object_id.blank? ? nil : table[:citation_object_id].eq(citation_object_id)  
      end

      # @return [Arel::Node, nil]
      def matching_source_id
        source_id.blank? ? nil : table[:source_id].eq(source_id)  
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Citation.where(and_clauses)
        else
          ::Citation.all
        end
      end

      # @return [Arel::Table]
      def table
        ::Citation.arel_table
      end
    end
  end
end
