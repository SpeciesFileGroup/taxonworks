module Queries
  module TaxonName 

    class Filter << Queries::Query

      include Queries::Concerns::Tags
      
      attr_accessor :type

      attr_accessor :nomenclature_group

      # []
      attr_accessor :parent_id

      attr_accessor :exact

      attr_accessor :as_object

      attr_accessor :as_subject

      attr_accessor :status
      
      attr_accessor :keyword_ids

      attr_accessor :valid

      # [ ]
      attr_accessor :in_relationship

      def initialize(params)
      end

      # @return [Arel::Table]
      def table
        ::TaxonName.arel_table
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []
        clauses += attribute_clauses
       
        clauses += [
          between_date_range,
          matching_any_label,
          matching_verbatim_locality,
        ].compact
        
        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def merge_clauses
        clauses = [
          matching_keyword_ids,
          matching_shape,
          matching_spatial_via_geographic_area_ids

          # matching_verbatim_author
        ].compact

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

        q = nil 
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::TaxonName.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::TaxonName.all
        end

        q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end
  
      protected

    end
  end
end
