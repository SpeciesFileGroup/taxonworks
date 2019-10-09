module Queries
  module AssertedDistribution

    # !! does not inherit from base query
    class Filter 

      # Boolean 
      attr_accessor :recent

      attr_accessor :otu_id

      attr_accessor :geographic_area_id

      def initialize(params)
        @otu_id= params[:otu_id]
        @geographic_area_id = params[:geographic_area_id] 
        @recent = params[:recent] ? true : nil
      end

      # @return [Arel::Table]
      def table
        ::AssertedDistribution.arel_table
      end

      def asserted_distribution_attribute_equals(attribute)
        a = send(attribute)
        a.blank? ? nil : table[attribute].eq(a)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []
       
        clauses += [
          asserted_distribution_attribute_equals(:otu_id),
          asserted_distribution_attribute_equals(:geographic_area_id),
        ].compact
        
        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = nil

        q = nil 
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::AssertedDistribution.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::AssertedDistribution.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end
  
      protected

    end
  end
end
