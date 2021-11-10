module Queries
  module DwcOccurrence


    # Keep this minimal, in pricinple filtering should be done on the base objects, not the core here.
    class Filter < Queries::Query

      include Queries::Helpers
      include Queries::Concerns::Users

      attr_accessor :dwc_occurrence_object_id
      attr_accessor :dwc_occurrence_object_type

      def initialize(params)
        set_user_dates(params)
      end

      # @return [Arel::Table]
      def table
        ::DwcOccurrence.arel_table
      end

      def base_query
        ::DwcOccurrence.select('dwc_occurrences.*')
      end

      def dwc_occurrence_object_id
        [@dwc_occurrence_object_id].flatten.compact
      end

      def dwc_occurrence_object_type
        [@dwc_occurrence_object_type].flatten.compact
      end

      def dwc_occurrence_object_id_facet
        return nil if dwc_occurrence_object_id.empty?
        table[:dwc_occurrence_object_id].eq_any(dwc_occurrence_object_id)
      end

      def dwc_occurrence_object_type_facet
        return nil if dwc_occurrence_object_type.empty?
        table[:dwc_occurrence_object_type].eq_any(dwc_occurrence_object_type)
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

        clauses += [
          dwc_occurrence_object_id_facet,
          dwc_occurrence_object_type_facet
        ]

        clauses.compact!
        clauses
      end

      def base_merge_clauses
        clauses = []

        clauses += [
          created_updated_facet,  # See Queries::Concerns::Users
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
        if a && b
          b.where(a).distinct
        elsif a
          ::DwcOccurrence.where(a).distinct
        elsif b
          q = b.distinct
        else
          ::DwcOccurrence.all
        end
      end
    end
  end
end
