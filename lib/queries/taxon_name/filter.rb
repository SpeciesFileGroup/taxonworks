module Queries
  module TaxonName 

    class Filter < Queries::Query

      include Queries::Concerns::Tags

      attr_accessor :name

      # Use "&" for and
      attr_accessor :author

      # String
      #   yyyy
      attr_accessor :year

      # Boolean
      #   true if only valid, false if only invalid, nil if both 
      attr_accessor :exact

      # String
      #   yyyy-mm-dd 
      attr_accessor :updated_since 

      # Boolean
      #   true if only valid, false if only invalid, nil if both 
      attr_accessor :validity

      # []
      # includes self 
      attr_accessor :parent_id

      # Boolean
      #   when parent_id[] provided then all children are as well, otherwise ignored
      attr_accessor :descendants

      # taxon_name_relationship[]= {}
      attr_accessor :taxon_name_relationship

      attr_accessor :taxon_name_classification

      # []
      attr_accessor :nomenclature_group

      # :without
      # :with
      attr_accessor :type_metadata

      # true
      # false 
      attr_accessor :cited

      # true
      # false 
      attr_accessor :otus

      attr_accessor :project_id


      def initialize(params)
        @name = params[:name]
        @author = params[:author]
        @year = params[:year].to_s 

        @exact = (params[:exact] == 'true' ? true : false) if !params[:exact].nil?
        @validity = (params[:validity] == 'true' ? true : false) if !params[:validity].nil?

        @descendants = (params[:descendants] == 'true' ? true : false) if !params[:descendants].nil?

        @updated_since = params[:updated_since].to_s 
        @keyword_ids ||= []

        @taxon_name_relationship = params[:taxon_name_relationship] || {}

        @project_id = params[:project_id]
        @parent_id = params[:parent_id] || []
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

      # merge facet
      def parent_facet
        return nil if parent_id.empty? || descendants
        table[:parent_id].eq_any(parent_id)
      end

      # @return Scope
      #   names that are not leaves
      def descendant_facet
        return nil if parent_id.empty? || !descendants
        o = table
        h = ::TaxonNameHierarchy.arel_table

        a = o.alias('a_')
        b = o.project(a[Arel.star]).from(a)

        c = h.alias('desc1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:descendant_id])
        )

        e = c[:descendant_id].not_eq(nil)
        f = c[:ancestor_id].eq_any(parent_id)

        b = b.where(e.and(f))
        b = b.group(a[:id])
        b = b.as('tndes_')

        ::TaxonName.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(table['id']))))
      end

      # @return Scope
      #   meta, should not 
      def taxon_name_relationship_facet(hsh, trn_alias = '1') 
        o = table
        h = ::TaxonNameRelationship.arel_table

        a = o.alias("ta_#{trn_alias}_")
        b = o.project(a[Arel.star]).from(a)

        c = h.alias("tnr#{trn_alias}")

        trg = hsh['subject_taxon_name_id'] ? 'subject_taxon_name_id' : 'object_taxon_name_id'
        opp = hsh['subject_taxon_name_id'] ? 'object_taxon_name_id' : 'subject_taxon_name_id'

        typ = hsh['type']

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[opp]).
            and(c[:type].eq(typ))
        )

        e = c[trg].not_eq(nil)
        f = c[trg].eq(hsh[trg])

        b = b.where(e.and(f))
        b = b.group(a[:id])
        b = b.as("tnr_a_#{trn_alias}_")

        ::TaxonName.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(table['id']))))
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
          parent_facet,  
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
          descendant_facet,
          matching_keyword_ids,
        ].compact

        i = 0
        taxon_name_relationship.each do |k, values|
          clauses << taxon_name_relationship_facet(values, i.to_s)
          i += 1
        end

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
