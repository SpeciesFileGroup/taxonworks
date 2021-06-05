module Queries
  module Extract

    # TODO 
    # - use date processing? / DateConcern
    # - syncronize with GIS/GEO

    class Filter < Queries::Query

      include Queries::Helpers

      include Queries::Concerns::Tags
      include Queries::Concerns::Users
      include Queries::Concerns::Identifiers

      # @param [String, nil]
      #  'true' - order by updated_at
      #  'false', nil - do not apply ordering
      # @return [Boolen, nil]
      attr_accessor :recent

      # @return [Array of Repository#id]
      attr_accessor :repository_id

      # @param [Hash] args are permitted params
      def initialize(params)
        @respository_id = params[:respository_id] 
        @recent = boolean_param(params, :recent)

        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)
      end

      # @return [Arel::Table]
      def table
        ::Extract.arel_table
      end

      def base_query
        ::Extract.select('extracts.*')
      end

      def repository_id
        [@repository_id].flatten.compact
      end

      def repository_id_facet
        return nil if repository_id.blank?
        table[:repository_id].eq_any(repository_id)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = base_and_clauses

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Array]
      def base_and_clauses
        clauses = []
        # clauses += [ ]
        # clauses.compact!
        clauses
      end

      def base_merge_clauses
        clauses = []

        clauses += [
          repository_id_facet,
          keyword_id_facet,       # See Queries::Concerns::Tags
          created_updated_facet,  # See Queries::Concerns::Users
          identifiers_facet,      # See Queries::Concerns::Identifiers
          identifier_between_facet,
          identifier_facet,
          identifier_namespace_facet,
        ]

        clauses.compact!
        clauses
      end

      # @return [ActiveRecord::Relation]
      def merge_clauses
        clauses = base_merge_clauses        
        return nil if clauses.empty?
        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses
        # q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::Extract.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::Extract.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end

    end
  end
end
