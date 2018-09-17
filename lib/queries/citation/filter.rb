module Queries
  module Citation

    # !! does not inherit from base query
    class Filter 
      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      # attr_accessor :options

      # Array, Integer
      attr_accessor :citation_object_type, :citation_object_id, :source_id, :polymorphic_ids

      # @params params [ActionController::Parameters]
      #   already Permitted
      def initialize(params)
        @citation_object_type = params[:citation_object_type]
        @citation_object_id = params[:citation_object_id]
        @source_id = params[:source_id]
        set_polymorphic_ids(params)
      end

      def polymorphic_ids=(hash)
        set_polymorphic_ids(hash)
      end 

      def set_polymorphic_ids(hash)
        @polymorphic_ids = hash.select{|k,v| ::Citation.related_foreign_keys.include?(k.to_s)} 
        @polymorphic_ids ||= {}
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

      # TODO: Dry with polymorphic_params
      # @return [Arel::Node, nil]
      def matching_polymorphic_ids
        nodes = Queries::Annotator.polymorphic_nodes(polymorphic_ids, ::Citation)
        return nil if nodes.nil?
        a = nodes.shift
        nodes.each do |b|
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
          ::Citation.none
        end
      end

      # @return [Arel::Table]
      def table
        ::Citation.arel_table
      end
    end
  end
end
