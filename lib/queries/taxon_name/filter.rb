module Queries
  module TaxonName 

    # https://api.taxonworks.org/#/taxon_names
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

      # @params taxon_name_id [Array]
      #   An array of taxon_name_id.
      # @return
      #   Return the taxon name(s) with this/these ids 
      attr_accessor :taxon_name_id

      # @params parent_id[] [Array]
      #   An array of taxon_name_id.
      # @return
      #   Return all immediate children to any of these parent names
      attr_accessor :parent_id

      # @param descendants [Boolean]
      # ['true' or 'false'] on initialize
      #   Ignored when taxon_name_id[].empty? Return descendants of parents as well.
      attr_accessor :descendants

      # @param taxon_name_relationship [Array]
      #  [ { 'type' => 'TaxonNameRelationship::<>', 'subject|object_taxon_name_id' => '123' } ... {} ] 
      # Each entry must have a 'type'
      # Each entry must have one (and only one) of 'subject_taxon_name_id' or 'object_taxon_name_id'
      #
      # Return all taxon names in a relationship of a given type and in relation to a another name. For example, return all synonyms of Aus bus.
      attr_accessor :taxon_name_relationship

      # @param taxon_name_relationship [Array]
      #   All names involved in any of these relationship
      attr_accessor :taxon_name_relationship_type

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

      # @param otus [Boolean, nil]
      # ['true' or 'false'] on initialize
      #   whether the name has an Otu
      attr_accessor :otus

      # @param authors [Boolean, nil]
      # ['true' or 'false'] on initialize
      #   whether the name has an author string, from any source, provided 
      attr_accessor :authors

      # @params type_material [Boolean, nil]
      # ['true' or 'false'] on initialize
      #   whether the name has TypeMaterial
      attr_accessor :type_metadata 

      # @return [Array, nil]
      #   &nomenclature_group=<Higher|Family|Genus|Species>>
      attr_accessor :nomenclature_group

      # @return [Array, nil]
      #   &nomenclature_code=Iczn|Icnp|Icn|Ictv
      attr_accessor :nomenclature_code

      # TODO: inverse is duplicated in autocomplete
      # @return [Boolean, nil]
      #   &leaves=<"true"|"false">
      #   if 'true' then return only names without descendents
      #   if 'false' then return only names with descendents
      attr_accessor :leaves

      # @return [String, nil]
      #   &taxon_name_type=<Protonym|Combination|Hybrid>
      attr_accessor :taxon_name_type

      # @param params [Params] 
      #   a permitted via controller
      def initialize(params)
        @author = params[:author]
        @authors = (params[:authors]&.downcase == 'true' ? true : false) if !params[:authors].nil?
        @citations = params[:citations]
        @descendants = (params[:descendants]&.downcase == 'true' ? true : false) if !params[:descendants].nil?
        @exact = (params[:exact]&.downcase == 'true' ? true : false) if !params[:exact].nil?
        @leaves = (params[:leaves]&.downcase == 'true' ? true : false) if !params[:leaves].nil?
        @name = params[:name]
        @nomenclature_code = params[:nomenclature_code]  if !params[:nomenclature_code].nil?
        @nomenclature_group = params[:nomenclature_group]  if !params[:nomenclature_group].nil?
        @otus = (params[:otus]&.downcase == 'true' ? true : false) if !params[:otus].nil?
        @project_id = params[:project_id]
        @taxon_name_classification = params[:taxon_name_classification] || [] 
        @taxon_name_id = params[:taxon_name_id] || []
        @parent_id = params[:parent_id] || []
        @taxon_name_relationship = params[:taxon_name_relationship] || [] 
        @taxon_name_relationship_type = params[:taxon_name_relationship_type] || [] 
        @taxon_name_type = params[:taxon_name_type]
        @type_metadata = (params[:type_metadata]&.downcase == 'true' ? true : false) if !params[:type_metadata].nil?
        @updated_since = params[:updated_since].to_s 
        @validity = (params[:validity]&.downcase == 'true' ? true : false) if !params[:validity].nil?
        @year = params[:year].to_s 
        
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
        return nil unless @nomenclature_group
        "NomenclaturalRank::%#{@nomenclature_group}%"
      end

      # @return [String, nil] 
      #   accessor for attr :nomenclature_code, wrap with needed wildcards
      def nomenclature_code
        return nil unless @nomenclature_code
        "NomenclaturalRank::#{@nomenclature_code}%"
      end

      # @return Scope
      #   match only names that are a descendant of some taxon_name_id 
      # A merge facet.
      def descendant_facet
        return nil if taxon_name_id.empty? || descendants == false
        ::TaxonName.where(
          ::TaxonNameHierarchy.where(
            ::TaxonNameHierarchy.arel_table[:descendant_id].eq(::TaxonName.arel_table[:id]).and(
            ::TaxonNameHierarchy.arel_table[:ancestor_id].in(taxon_name_id)) # TODO- is likely not the most optimal
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
      def authors_facet
        return nil if authors.nil?
        authors ? 
          ::TaxonName.where.not(cached_author_year: nil) :
          ::TaxonName.where(cached_author_year: nil)
      end

      # @return Scope
      def taxon_name_relationship_type_facet
        return nil if taxon_name_relationship_type.empty?
        ::TaxonName.with_taxon_name_relationship(taxon_name_relationship_type)
      end

      # @return Scope
      def leaves_facet
        return nil if leaves.nil?
        leaves ? ::TaxonName.leaves : ::TaxonName.not_leaves
      end

      # @return Scope
      #   wrapped in descendant_facet!
      def taxon_name_relationship_facet(hsh)
        param_key = hsh['subject_taxon_name_id'] ? 'subject_taxon_name_id' : 'object_taxon_name_id'
        join_key = hsh['subject_taxon_name_id'] ? 'object_taxon_name_id' : 'subject_taxon_name_id'

        ::TaxonName.where(
          ::TaxonNameRelationship.where(
            ::TaxonNameRelationship.arel_table[join_key].eq(::TaxonName.arel_table[:id]).and(
            ::TaxonNameRelationship.arel_table[param_key].eq(hsh[param_key])).and(
            ::TaxonNameRelationship.arel_table[:type].eq(hsh['type']))
          ).arel.exists
        )
      end

      # @return Scope
      def taxon_name_classification_facet
        return nil if taxon_name_classification.empty?

        ::TaxonName.where(
          ::TaxonNameClassification.where(
            ::TaxonNameClassification.arel_table[:taxon_name_id].eq(::TaxonName.arel_table[:id]).and(
            ::TaxonNameClassification.arel_table[:type].in(taxon_name_classification))
          ).arel.exists
        )
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

        citation_conditions = ::Citation.arel_table[:citation_object_id].eq(::TaxonName.arel_table[:id]).and(
          ::Citation.arel_table[:citation_object_type].eq('TaxonName'))

        if citations == 'without_origin_citation'
          citation_conditions = citation_conditions.and(::Citation.arel_table[:is_original].eq(true))
        end

        ::TaxonName.where.not(::Citation.where(citation_conditions).arel.exists)
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

      def taxon_name_type_facet
        return nil if taxon_name_type.blank?
        table[:type].eq(taxon_name_type)
      end

      def cached_name
        return nil if name.blank?
        if exact
          table[:cached].eq(name.strip)
        else
          table[:cached].matches('%' + name.strip.gsub(/\s+/, '%') + '%')
        end
      end

      def parent_id_facet 
        return nil if parent_id.empty?
          table[:parent_id].eq_any(parent_id)
      end

      def author_facet 
        return nil if author.blank?
        if exact
          table[:cached_author_year].eq(author.strip)
        else
          table[:cached_author_year].matches('%' + author.strip.gsub(/\s/, '%') + '%')
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

      def taxon_name_id_facet
        return nil if taxon_name_id.empty? || descendants
        table[:id].eq_any(taxon_name_id)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []

        clauses += [
          parent_id_facet,
          author_facet,
          cached_name,
          year_facet,
          updated_since_facet,
          validity_facet,
          taxon_name_id_facet,
          with_nomenclature_group,
          with_nomenclature_code,
          taxon_name_type_facet
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
          taxon_name_relationship_type_facet,
          leaves_facet,
          descendant_facet,
          taxon_name_classification_facet,
          matching_keyword_ids,
          type_metadata_facet,
          otus_facet,
          authors_facet,
          citations_facet
        ].compact

        taxon_name_relationship.each do |hsh|
          clauses << taxon_name_relationship_facet(hsh)
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
          q = b.where(a)
        elsif a
          q = ::TaxonName.where(a)
        elsif b
          q = b
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
