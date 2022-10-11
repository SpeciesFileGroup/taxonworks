module Queries
  module AssertedDistribution

    # !! does not inherit from base query
    class Filter 


      include Queries::Concerns::Citations

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :otu_id
     
      # @param otu_id [Array, Integer, String]
      # @return [Array]
      attr_accessor :geographic_area_id

      # Add citations extension

      # @param sourceid [Array, Integer, String]
      # @return [Array]
      # attr_accessor :source_id

      # @param otu_id [Array, Integer, String]
      # @return [Array]
      # attr_accessor :is_original

      # TODO: replicate the TaxonName Parenthood params here
      # attr_accessor ancestor

      # TODO add spatial option for ancestor
      # @param attr_accessor ancestor_scope [String, Symbol, nil]
      # @return [Symbol, nil]
      #   `spatial` - treat spatial 
      #   `parent` - use closure tree (parenthood)
      #   `expanded` - start with spatial, then for each spatial use parent
      #   `inverse_expanded` - start with parent, then for each use spatial (only make sense for non-spatial parents with some spatial children)
      
      # @return [Boolean, nil]
      # @params recent ['true', 'false', nil]
      attr_accessor :recent

      def initialize(params)
        @otu_id = params[:otu_id]
        @geographic_area_id = params[:geographic_area_id]
  
        @recent = params[:recent].blank? ? nil : params[:recent].to_i

        set_citations_params(params)
      end

      def otu_id
        [@otu_id].flatten.compact
      end

      def geographic_area_id
        [@geographic_area_id].flatten.compact
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

      def base_and_clauses
        clauses = []
        clauses += [
          asserted_distribution_attribute_equals(:otu_id),
          asserted_distribution_attribute_equals(:geographic_area_id),
        ].compact
      end

      # TODO: not used
      def base_merge_clauses
        []
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
