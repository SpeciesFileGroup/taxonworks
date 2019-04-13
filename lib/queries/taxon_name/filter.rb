module Queries
  module TaxonName 

    class Filter < Queries::Query

      include Queries::Concerns::Tags
    
      # -- General --

      attr_accessor :name

      # Use "&" for and
      attr_accessor :author

      attr_accessor :year

      attr_accessor :exact

      attr_accessor :updated_since # yyyy/mm/dd 

      attr_accessor :validity # :invalid, :valid (leave out for both)

      # Boolean
      attr_accessor :include_ancestors 

      attr_accessor :taxon_name_relationship
      # taxon_name_relationship[]=

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
        @exact = (params[:exact] == 'true' ? true : false) if !params[:exact].nil?
        @validity = (params[:validity] == 'true' ? true : false) if !params[:exact].nil?
        @author = params[:author]
        @year = params[:year].to_s 
        @updated_since = params[:updated_since].to_s 
        @keyword_ids ||= []
      end

      # @return [Arel::Table]
      def table
        ::TaxonName.arel_table
      end

      def year=(value)
        @year = value.to_s
      end

      def cached_name
        return nil if name.blank?
        if exact
          table[:cached].eq(name)
        else
          table[:cached].matches('%' + name + '%')
        end
      end

      def author_facet 
        return nil if author.blank?
        if exact
          table[:cached_author_year].eq(author)
        else
          table[:cached_author_year].matches('%' + author + '%')
        end
      end

      def year_facet 
        return nil if year.blank?
        table[:cached_author_year].matches('%' + year + '%')
      end

      def updated_since_facet
        return nil if updated_since.blank?
        table[:updated_at].gt(Date.parse(updated_since))
      end

      def validity_facet 
        return nil if validity.nil? 
        if validity 
          table[:id].eq(table[:cached_valid_taxon_name_id])
        else
          table[:id].not_eq(table[:cached_valid_taxon_name_id])
        end
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []
       
        clauses += [
          author_facet,
          cached_name,
          year_facet,
          updated_since_facet,
          validity_facet,
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
