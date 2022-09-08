module Queries
  module AssertedDistribution

    # !! does not inherit from base query
    class Filter 

      # @return [Array]
      # @param otu_id [Array, Integer, String]
      attr_accessor :otu_id

      # @return [Array]
      # @param otu_id [Array, Integer, String]
      attr_accessor :geographic_area_id

      # @return [Array]
      # @param otu_id [Array, Integer, String]
      attr_accessor :geographic_area_id

      # @return [Boolean, nil]
      # @params recent ['true', 'false', nil]
      attr_accessor :recent

      def initialize(params)
        if p = params[:otu_id]
          if p.kind_of? Array
            @otu_id = params[:otu_id]
          else
            @otu_id = [params[:otu_id]]
          end
        end

        if p = params[:geographic_area_id]
          if p.kind_of? Array
            @geographic_area_id = params[:geographic_area_id]
          else
            @geographic_area_id = [params[:geographic_area_id]]
          end
        end

        @recent = params[:recent].blank? ? nil : params[:recent].to_i
      end

      # @return [Arel::Table]
      def table
        ::AssertedDistribution.arel_table
      end

      def asserted_distribution_attribute_equals(attribute)
        a = send(attribute)
        if a
          return a.empty? ? nil : table[attribute].eq_any(a)
        end
        nil
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

        q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end
  
      protected

    end
  end
end
