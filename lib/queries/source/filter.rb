module Queries
  module Source

    # TODO: UI needs singular updates for:
    # 
    #   
    #
    #
    class Filter < Query::Filter

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes
      include Queries::Concerns::Empty

      # TODO: move to model replicated in CollectingEvent
      # TOOD: confirm cached should not be a target
      ATTRIBUTES = (::Source.column_names - %w{id project_id created_by_id updated_by_id created_at updated_at cached})
      #  ATTRIBUTES.each do |a|
      #    class_eval { attr_accessor a.to_sym }
      #  end

      def self.permit(params)
        params.permit( 
          :ancestor_id, # TODO: review vs. taxon_name_id
          :author,
          :author_ids_or, # TODO: singularize
          :bibtex_type,
          :citations_on_otus,
          :documents,
          :exact_author,
          :exact_title,
          :in_project,
          :nomenclature,
          :per,
          :project_id,
          :query_term,
          :recent,
          :roles,
          :serial,
          :source_type,
          :title,
          :with_doi,
          :with_title,
          :year_end,
          :year_start,
          author_ids: [], # TODO: singularize
          bibtex_type: [],
          citation_object_type: [],
          ids: [], # TODO: singularize
          keyword_id_and: [],
          keyword_id_or: [],
          topic_ids: [], # TODO: singularize
          serial_ids: [], # TODO: singularize
          empty: [],
          not_empty: []
        )
      end

=begin
      PARAMS = ATTRIBUTES.collect{|a| a.to_sym} + [
        :ancestor_id,
        :author,
        :author_ids_or,
        :bibtex_type,
        :citations_on_otus,
        :documents,
        :exact_author,
        :exact_title,
        :in_project,
        :nomenclature,
        :per,
        :project_id,
        :query_term,
        :recent,
        :roles,
        :serial,
        :source_type,
        :title,
        :with_doi,
        :with_title,
        :year_end,
        :year_start,
        author_ids: [],
        bibtex_type: [],
        citation_object_type: [],
        ids: [],
        keyword_id_and: [],
        keyword_id_or: [],
        topic_ids: [],
        serial_ids: [],
        empty: [],
        not_empty: []
      ] 
=end


      # @project_id from Queries::Query
      #   used in context of in_project when provided
      #   must also include `in_project=true|false`

      # @return [Boolean, nil]
      # @params in_project ['true', 'false', nil]
      # ! requires `project_id`
      attr_accessor :in_project

      # @return author [String, nil]
      attr_accessor :author

      # TODO: Change to source_id
      # @return ids [Array of Integer, nil]
      attr_accessor :ids

      # @return [Boolean, nil]
      # @params exact_author ['true', 'false', nil]
      attr_accessor :exact_author

      # @params author [Array of Integer, Person#id]
      attr_accessor :author_ids

      # @params author [Boolean, nil]
      attr_accessor :author_ids_or

      # @params author [Array of Integer, Topic#id]
      attr_accessor :topic_ids

      # @params year_start [Integer, nil]
      attr_accessor :year_start

      # @params year_end [Integer, nil]
      attr_accessor :year_end

      # @params title [String, nil]
      attr_accessor :title

      # @return [Boolean, nil]
      # @params exact_title ['true', 'false', nil]
      attr_accessor :exact_title

      # !! TODO - conflicts with citations?  !! - yes, this is *used in citations*
      # @return [Boolean, nil]
      # @params citations ['true', 'false', nil]
      attr_accessor :citations

      # @return [Boolean, nil]
      # @params recent ['true', 'false', nil]
      attr_accessor :recent

      # @return [Boolean, nil]
      # @params roles ['true', 'false', nil]
      attr_accessor :roles

      # @return [Boolean, nil]
      # @params documentation ['true', 'false', nil]
      attr_accessor :documents

      # @return [Boolean, nil]
      # @params nomenclature ['true', 'false', nil]
      attr_accessor :nomenclature

      # @return [Boolean, nil]
      # @params with_doi ['true', 'false', nil]
      attr_accessor :with_doi

      # TODO: move tc citations concern
      # @return [Array, nil]
      # @params citation_object_type  [Array of ObjectType]
      attr_accessor :citation_object_type

      # From lib/queries/concerns/tags.rb
      # attr_accessor :tags

      # @return [String, nil]
      # @params source_type ['Source::Bibtex', 'Source::Human', 'Source::Verbatim']
      attr_accessor :source_type

      # @params author [Array of Integer, Serial#id]
      attr_accessor :serial_ids

      # @return [Protonym.id, nil]
      #   return all sources in Citations linked to this name or descendants
      #   to this TaxonName
      attr_accessor :ancestor_id

      # @return [Boolean]
      # @params citations_on_otus ['false', 'true']
      #   ignored if ancestor_id is not provided; if true then also include sources linked to OTUs that are in the scope of ancestor_id
      attr_accessor :citations_on_otus

      # @return [Boolean, nil]
      # true - with serial_id
      # false - without_serial_id
      # nil - both
      attr_accessor :serial

      # @return [Boolean, nil]
      # true - with a title 
      # false - without a title
      # nil - both
      attr_accessor :with_title

      # @return [Array, String, nil]
      # one of the allowed BibTeX types 
      attr_accessor :bibtex_type

      # @param [Hash] params
      def initialize(params)
        @query_string = params[:query_term]&.delete("\u0000") # TODO, we need to sanitize params in general.

        @ancestor_id = params[:ancestor_id]
        @author = params[:author]
        @author_ids = params[:author_ids] || []
        @author_ids_or =  boolean_param(params,:author_ids_or)
        @bibtex_type = params[:bibtex_type]
        @citation_object_type = params[:citation_object_type] || []
        @citations = boolean_param(params,:citations) # TODO: rename coming to reflect conflict with Citations concern
        @citations_on_otus = boolean_param(params,:citations_on_otus)
        @documents = boolean_param(params,:documents)
        @exact_author = boolean_param(params,:exact_author)
        @exact_title = boolean_param(params,:exact_title)
        @ids = params[:ids] || []
        @in_project = boolean_param(params,:in_project) 
        @nomenclature = boolean_param(params,:nomenclature)
        @project_id = params[:project_id] # TODO: also in Queries::Query
        @recent =  boolean_param(params,:recent)
        @roles = boolean_param(params,:roles)
        @serial = boolean_param(params,:serial)
        @serial_ids = params[:serial_ids] || []
        @source_type = params[:source_type]
        @title = params[:title]
        @topic_ids = params[:topic_ids] || []
        @with_doi = boolean_param(params, :with_doi)
        @with_title = boolean_param(params, :with_title)
        @year_end = params[:year_end]
        @year_start = params[:year_start]

        build_terms

        set_tags_params(params)
        set_user_dates(params)
        set_empty_params(params)
        super
      end

      # @return [Arel::Table]
      def project_sources_table
        ::ProjectSource.arel_table
      end

      def bibtex_type
        [@bibtex_type].flatten.compact.uniq
      end

      def bibtex_type_facet
        return nil if bibtex_type.empty?
        table[:type].eq('Source::Bibtex').and(table[:bibtex_type].eq_any(bibtex_type))
      end

      # Return all citations on Taxon names and descendants,
      # and optionally OTUs.
      def ancestors_facet
        return nil if ancestor_id.nil?

        joins = [
          ancestor_taxon_names_join,
          ancestor_taxon_name_classifications_join,
          ancestor_taxon_name_relationship_join(:subject_taxon_name_id),
          ancestor_taxon_name_relationship_join(:object_taxon_name_id)
        ]

        joins.push ancestor_otus_join if citations_on_otus

        union = joins.collect{|j| '(' + ::Source.joins(:citations).joins( j.join_sources).to_sql + ')'}.join(' UNION ')

        ::Source.from("( #{union} ) as sources")
      end

      def source_type_facet
        return nil if source_type.blank?
        table[:type].eq(source_type)
      end

      def year_facet
        return nil if year_start.blank?
        if year_start && !year_end.blank?
          table[:year].gteq(year_start)
            .and(table[:year].lteq(year_end))
        else # only start
          table[:year].eq(year_start)
        end
      end

      def source_ids_facet
        ids.empty? ? nil : table[:id].eq_any(ids)
      end

      def serial_ids_facet
        serial_ids.empty? ? nil : table[:serial_id].eq_any(serial_ids)
      end

      def author_ids_facet
        return nil if author_ids.empty?
        o = table
        r = ::Role.arel_table

        a = o.alias("a_")
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
          .and(c[:role_object_type].eq('Source'))
          .and(c[:type].eq('SourceAuthor'))
          )

        e = c[:id].not_eq(nil)
        f = c[:person_id].eq_any(author_ids)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(author_ids.length)) unless author_ids_or
        b = b.as('aut_z1_')

        ::Source.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      def topic_ids_facet
        ::Source.joins(:citation_topics).where(citation_topics: { topic_id: topic_ids }).distinct unless topic_ids.empty?
      end

      def in_project_facet
        return nil if project_id.nil? || in_project.nil?

        if in_project
          ::Source.joins(:project_sources)
            .where(project_sources: {project_id:})
        else
          ::Source.left_outer_joins(:project_sources)
            .where('project_sources.project_id != ? OR project_sources.id IS NULL', Current.project_id) # TODO: probably project_id
            .distinct
        end
      end

      # Over-rides Query::Filter identifier_type_facet to handle with_doi exception
      def identifier_type_facet
        return nil if identifier_type.empty? || with_doi
        q = referenced_klass.joins(:identifiers)
        w = identifier_table[:type].eq_any(identifier_type)
        q.where(w)
      end

      # TODO: move to generalized code in Identifiers concern
      def with_doi_facet
        return nil if with_doi.nil?
        if with_doi
          ::Source.joins(:identifiers).where(identifiers: {type: 'Identifier::Global::Doi'})
        else
          ::Source.left_outer_joins(:identifiers).where("(identifiers.type != 'Identifier::Global::Doi') OR (identifiers.identifier_object_id is null)")
        end
      end

      def with_title_facet
        return nil if with_title.nil?

        if with_title
          table[:title].not_eq(nil)
        else
          table[:title].eq(nil)
        end
      end

      # TODO: move to a concern
      def role_facet
        return nil if roles.nil?

        if roles
          ::Source.joins(:roles).distinct
        else
          ::Source.left_outer_joins(:roles)
            .where(roles: {id: nil})
        end
      end

      # TODO: move to a concern
      def document_facet
        return nil if documents.nil?

        if documents
          ::Source.joins(:documents).distinct
        else
          ::Source.left_outer_joins(:documents)
            .where(documents: {id: nil})
            .distinct
        end
      end

      def serial_facet
        return nil if serial.nil?

        if serial
          table[:serial_id].not_eq(nil)
        else
          table[:serial_id].eq(nil)
        end
      end

      def citation_object_type_facet
        return nil if citation_object_type.empty?
        ::Source.joins(:citations)
          .where(citations: {citation_object_type: citation_object_type}).distinct
      end

      def nomenclature_facet
        return nil if nomenclature.nil?

        if nomenclature
          ::Source.joins(:citations)
            .where(citations: {citation_object_type: ['TaxonName', 'TaxonNameRelationship', 'TaxonNameClassification', 'TypeMaterial']})
            .distinct
        else
          ::Source.left_outer_joins(:citations)
            .where("(citations.citation_object_type NOT IN ('TaxonName','TaxonNameRelationship','TaxonNameClassification','TypeMaterial')) OR (citations.id is null)")
            .distinct
        end
      end

      # Over-ride the inclusion of this facet at the Filter level.
      def project_id_facet
        nil
      end

      def base_merge_clauses
        [
          ancestors_facet,
          author_ids_facet,
          citation_object_type_facet,
          document_facet,
          empty_fields_facet,    # See Queries::Concerns::Empty
          in_project_facet,
          nomenclature_facet,
          not_empty_fields_facet,
          role_facet,
          topic_ids_facet,
          with_doi_facet,
        ]
      end

      # @return [ActiveRecord::Relation]
      def base_and_clauses
        [
          attribute_exact_facet(:author),
          attribute_exact_facet(:title),
          bibtex_type_facet,
          cached,
          serial_facet,
          serial_ids_facet,
          source_ids_facet,
          source_type_facet,
          with_title_facet,
          year_facet,
        ]
      end

      private

      def ancestor_otus_join
        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        o = ::Otu.arel_table

        c.join(o, Arel::Nodes::InnerJoin).on(
          o[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('Otu'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          o[:taxon_name_id].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

      def ancestor_taxon_names_join
        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonName.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonName'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[:id].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

      def ancestor_taxon_name_classifications_join
        return nil if ancestor_id.nil?

        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonNameClassification.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonNameClassification'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[:taxon_name_id].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

      def ancestor_taxon_name_relationship_join(join_on = :subject_taxon_name_id)
        return nil if ancestor_id.nil?

        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonNameRelationship.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonNameRelationship'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[join_on].eq(h[:descendant_id]).and(h[:ancestor_id].eq(ancestor_id))
        )
      end

    end
  end
end
