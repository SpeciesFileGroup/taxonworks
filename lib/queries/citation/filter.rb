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
      attr_accessor :citation_object_type, :citation_object_id, :source_id, :user_id

    # @return [Boolean, nil]
      # @params recent ['true', 'false', nil]
      attr_accessor :recent

      # Boolean
      attr_accessor :is_original

      # @params params [Hash]
      #   already Permitted params, or new Hash
      def initialize(params)
        @citation_object_type = params[:citation_object_type]
        @citation_object_id = params[:citation_object_id]
        @source_id = params[:source_id]
        @user_id = params[:user_id]
        @is_original = params[:is_original]
        @options = params
        @recent = boolean_param(params, :recent)
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          ::Queries::Annotator.annotator_params(options, ::Citation),
          matching_citation_object_type,
          matching_citation_object_id,
          matching_source_id,
          matching_updated_by_id,
          matching_is_original
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

      def matching_updated_by_id
        return nil if Current.user_id.nil?
        user_id == 'true' ? table[:updated_by_id].eq(Current.user_id) : nil
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
