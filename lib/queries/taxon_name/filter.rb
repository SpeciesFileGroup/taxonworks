module Queries
  module TaxonName 

    class Filter < Queries::Query

      include Queries::Concerns::Tags
    
      # -- General --

      attr_accessor :name

      attr_accessor :author

      attr_accessor :year

      attr_accessor :exact

      attr_accessor :updated_since # yyyy/mm/dd 

      attr_accessor :validity # :invalid, :valid (leave out for both)

      # Boolean
      attr_accessor :include_ancestors 


      attr_accessor :taxon_name_relationship
#       taxon_name_relationship[]=

      attr_accessor :taxon_name_classification

      # []
      attr_accessor :nomenclature_group

      # [] 
      attr_accessor :parent_id

      attr_accessor :keyword_ids

      # :without
      # :with
      attr_accessor :type_metadata

      # true
      # false 
      attr_accessor :cited

      # true
      # false 
      attr_accessor :otus


      def initialize(params)
        @name = params[:name]
        @keyword_ids ||= []
        @exact = params[:exact] == 'true' ? true : false 
      end


      # @return [Arel::Table]
      def table
        ::TaxonName.arel_table
      end

      def cached_name
        if exact
          table[:cached].eq(name)
        else
          table[:cached].matches('%' + name + '%')
        end
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []
       
        clauses += [
          cached_name,
          with_project_id
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

        #  q = q.order(updated_at: :desc).limit(recent) if recent
        q
      end
  
      protected

    end
  end
end
