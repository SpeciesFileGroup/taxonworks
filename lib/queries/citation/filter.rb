# To identify the polymorphic params, include the pertinent model we rereference here
# require_dependency Rails.root.to_s + '/app/models/collecting_event'

module Queries
  module Citation

    # !! does not inherit from base query
    class Filter
      include Queries::Helpers
      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Array, Integer
      attr_accessor :citation_object_type, :citation_object_id, :source_id

    # @return [Boolean, nil]
      # @params recent ['true', 'false', nil]
      attr_accessor :recent

      # Boolean
      attr_accessor :is_original

      # Params from Queries::Source::Filter
      attr_accessor :source_query

      # @params params [Hash]
      #   already Permitted params, or new Hash
      def initialize(params)
        @citation_object_type = params[:citation_object_type]
        @citation_object_id = params[:citation_object_id]
        @source_id = params[:source_id]
        @is_original = params[:is_original]
        @options = params

        @recent = boolean_param(params, :recent)

        @source_query = Queries::Source::Filter.new(
          params.select{|a,b| source_params.include?(a.to_s) }
        )
      end

      def merge_clauses
        c = []
        c = c + source_merge_clauses + source_and_clauses
        c.compact!
        c
      end

      def source_merge_clauses
        c = []
        # Convert base and clauses to merge clauses
        source_query.base_merge_clauses.each do |i|
          c.push ::Citation.joins(:source).merge( i )
        end
        c
      end

      def source_and_clauses
        c = []
        # Convert base and clauses to merge clauses
        source_query.base_and_clauses.each do |i|
          c.push ::Citation.joins(:source).where( i )
        end
        c
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          ::Queries::Annotator.annotator_params(options, ::Citation), # TODO: remove
          matching_citation_object_type,
          matching_citation_object_id,
          matching_source_id,
          matching_is_original
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def source_id
        [@source_id].flatten.compact
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
        source_id.blank? ? nil : table[:source_id].eq_any(source_id)  
      end

      def matching_is_original
        is_original.blank? ? nil : table[:is_original].eq(is_original)  
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          q = ::Citation.where(and_clauses).distinct
        else
          q =::Citation.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end

      # @return [Arel::Table]
      def table
        ::Citation.arel_table
      end
    end
  end
end
