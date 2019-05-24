module Queries
  module TaxonName 

    class Filter < Queries::Query

      include Queries::Concerns::Tags
 
      # @param name [String]
      #  Matches against cached.  See also exact.
      attr_accessor :name

      # @param author [String]
      #   Use "&" for "and". Matches against cached_author_year.
      attr_accessor :author

      # @param year [String]
      #   "yyyy"
      # Matches against cached_author_year.
      attr_accessor :year

      # @param exact [Boolean]
      #   true if matching must be exact, false if partial matches are allowed.
      attr_accessor :exact

      # @param updated_since [String] in format yyyy-mm-dd
      #  Names updated (.modified_at) since this date. 
      attr_accessor :updated_since 

      # @prams validity [ Boolean]
      # ['true' or 'false'] on initialize
      #   true if only valid, false if only invalid, nil if both 
      attr_accessor :validity

      # @params parent_id [Array]
      #   An array of taxon_name_id.
      # @return
      #   Return all children of these parents. Results includes self (parent_id).  
      attr_accessor :parent_id

      # @param descendants [Boolean]
      # ['true' or 'false'] on initialize
      #   Ignored when parent_id[].empty? Return descendants of parents as well.
      attr_accessor :descendants

      # @param taxon_name_relationship [Hash]
      #   { "0" => {'type' => 'TaxonNameRelationship::<>', 'subject|object_taxon_name_id' => '123'}, "1" => {} ... } 
      # Root keys are unique symbols, typically numbers.
      # Each entry must have a 'type'
      # Each entry must have one (and only one) of 'subject_taxon_name_id' or 'object_taxon_name_id'
      #
      # Return all taxon names in a relationship of a given type and in relation to a another name. For example, return all synonyms of Aus bus.
      attr_accessor :taxon_name_relationship

      # @param taxon_name_classification [Array]
      #   Class names of TaxonNameClassification, as strings.
      attr_accessor :taxon_name_classification

      # @param project_id [String]
      #   The project scope.
      # TODO: probably should be an array for API purposes.
      # TODO: unify globally as to whether param belongs here, or at controller level.
      attr_accessor :project_id 

      # @params citations [String]
      #  'without_citations' - names without citations
      #  'without_origin_citation' - names without an origin citation
      attr_accessor :citations

      # @param otus [Boolean]
      # ['true' or 'false'] on initialize
      #   whether the name has an Otu 
      attr_accessor :otus

      # @params type_material [Boolean]
      # ['true' or 'false'] on initialize
      #   whether the name has TypeMaterial
      attr_accessor :type_metadata 

      # @return [Array, nil]
      #   &nomenclature_group=<Higher|Family|Genus|Species>>
      attr_accessor :nomenclature_group

      # @return [Array, nil]
      #   &nomenclature_code=Iczn|Icnb|Icn|Ictv
      attr_accessor :nomenclature_code

      # @param params [Params] 
      #   a permitted via controller
      def initialize(params)
        @name = params[:name]
        @author = params[:author]
        @year = params[:year].to_s 
        @exact = (params[:exact] == 'true' ? true : false) if !params[:exact].nil?
        @parent_id = params[:parent_id] || []
        @descendants = (params[:descendants] == 'true' ? true : false) if !params[:descendants].nil?
        @updated_since = params[:updated_since].to_s 
        @validity = (params[:validity] == 'true' ? true : false) if !params[:validity].nil?
        @taxon_name_relationship = params[:taxon_name_relationship] || {}
        @taxon_name_classification = params[:taxon_name_classification] || [] 
        @type_metadata = (params[:type_metadata] == 'true' ? true : false) if !params[:type_metadata].nil?
        @citations = params[:citations]
        @otus = (params[:otus] == 'true' ? true : false) if !params[:otus].nil?
        @project_id = params[:project_id]

        @nomenclature_group = params[:nomenclature_group]  if !params[:nomenclature_group].nil?
        @nomenclature_code = params[:nomenclature_code]  if !params[:nomenclature_code].nil?

        # TODO: support here? 
        @keyword_ids ||= []
      end

      # @return [Arel::Table]
      def table
        ::TaxonName.arel_table
      end

      def year=(value)
        @year = value.to_s
      end
      
      # @return [String, nil] 
      #   accessor for attr :nomenclature_group, wrap with needed wildcards 
      def nomenclature_group
        @nomenclature_group ? "NomenclaturalRank::%#{@nomenclature_group}%" : nil
      end

      # @return [String, nil] 
      #   accessor for attr :nomenclature_code, wrap with needed wildcards 
      def nomenclature_code
        @nomenclature_code ? "NomenclaturalRank::#{@nomenclature_code}%" : nil
      end

      # @return Scope
      #   names that are not leaves
      # A merge facet.
      def descendant_facet
        return nil if parent_id.empty? || !descendants

        ::TaxonName.where(
          ::TaxonNameHierarchy.where(
            ::TaxonNameHierarchy.arel_table[:descendant_id].eq(::TaxonName.arel_table[:id]).and(
            ::TaxonNameHierarchy.arel_table[:ancestor_id].in(parent_id))
          ).arel.exists
        )
      end

      # @return Scope
      def otus_facet
        return nil if otus.nil?

        subquery = ::Otu.where(::Otu.arel_table[:taxon_name_id].eq(::TaxonName.arel_table[:id])).arel.exists

        ::TaxonName.where(otus ? subquery : subquery.not)
      end

      # @return Scope
      #   wrapped in descendant_facet!
      def taxon_name_relationship_facet(hsh, trn_alias = '1') 
        o = table
        h = ::TaxonNameRelationship.arel_table

        a = o.alias("tfb_#{trn_alias}_")
        b = o.project(a[Arel.star]).from(a)

        c = h.alias("tfb_r_#{trn_alias}")

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
        b = b.as("tfb_a_#{trn_alias}_")

        ::TaxonName.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(table['id']))))
      end

      # @return Scope
      def taxon_name_classification_facet
        return nil if taxon_name_classification.empty?
        o = table
        h = ::TaxonNameClassification.arel_table

        a = o.alias("tfc_")
        b = o.project(a[Arel.star]).from(a)

        c = h.alias("tfc_r_")

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:taxon_name_id])
        )

        e = c[:taxon_name_id].not_eq(nil)
        f = c[:type].eq_any(taxon_name_classification)

        b = b.where(e.and(f))
        b = b.group(a[:id])
        b = b.as("tfc_a_")

        ::TaxonName.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(table['id']))))
      end

      # @return Scope
      def type_metadata_facet
        return nil if type_metadata.nil?

        subquery = ::TypeMaterial.where(::TypeMaterial.arel_table[:protonym_id].eq(::TaxonName.arel_table[:id])).arel.exists

        ::TaxonName.where(type_metadata ? subquery : subquery.not)
      end

      # @return Scope
      def otus_facet
        return nil if otus.nil?

        subquery = ::Otu.where(::Otu.arel_table[:taxon_name_id].eq(::TaxonName.arel_table[:id])).arel.exists

        ::TaxonName.where(otus ? subquery : subquery.not)
      end

      # @return Scope
      def citations_facet 
        return nil if citations.nil?
        o = table
        h = ::Citation.arel_table

        a = o.alias("tff_")
        b = o.project(a[Arel.star]).from(a)

        c = h.alias("tff_r_")

        j = a[:id].eq(c[:citation_object_id]).
            and(c[:citation_object_type].eq('TaxonName'))

        j = j.and(c[:is_original].eq(true)) if citations == 'without_origin_citation'

        b = b.join(c, Arel::Nodes::OuterJoin).on(j)

        b = b.where(c[:id].eq(nil))
        b = b.group(a[:id])
        b = b.as("tff_a_")

        ::TaxonName.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(table['id']))))
      end

      # @return [Arel::Nodes::Grouping, nil]
      #   and clause
      def with_nomenclature_group
        return nil if nomenclature_group.nil?
        table[:rank_class].matches(nomenclature_group)
      end

      # @return [Arel::Nodes::Grouping, nil]
      #   and clause
      def with_nomenclature_code
        return nil if nomenclature_code.nil?
        table[:rank_class].matches(nomenclature_code)
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

      def parent_facet
        return nil if parent_id.empty? || descendants
        table[:parent_id].eq_any(parent_id)
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
          with_nomenclature_group,
          with_nomenclature_code,
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
          taxon_name_classification_facet,
          matching_keyword_ids,
          type_metadata_facet,
          otus_facet,
          citations_facet
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

        q = q.where(project_id: project_id) if project_id
        q
      end

      protected

    end
  end
end
