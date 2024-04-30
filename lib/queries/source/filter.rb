module Queries
  module Source
    class Filter < Query::Filter

      ATTRIBUTES =  (::Source.core_attributes - %w{bibtex_type title author serial_id}).map(&:to_sym).freeze

      include Queries::Concerns::DataAttributes
      include Queries::Concerns::Attributes
      include Queries::Concerns::Empty
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags

      PARAMS = [
        *ATTRIBUTES,
        :source_id,
        :taxon_name_id,
        :descendants,
        :author,
        :author_id_or,
        :bibtex_type,
        :citations,
        :citations_on_otus,
        :documents,
        :exact_author,
        :exact_title,
        :in_project,
        :nomenclature,
        :query_term,
        :roles,
        :serial,
        :source_type,
        :title,
        :with_doi,
        :with_title,
        :year_end,
        :year_start,
        author_id: [],
        bibtex_type: [],
        citation_object_type: [],
        empty: [],
        not_empty: [],
        serial_id: [],
        source_id: [],
        taxon_name_id: [],
        topic_id: [],
      ].freeze

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
      attr_accessor :source_id

      # @return [Boolean, nil]
      # @params exact_author ['true', 'false', nil]
      attr_accessor :exact_author

      # @params author [Array of Integer, Person#id]
      attr_accessor :author_id

      # @params author [Boolean, nil]
      #   `false`, nil - treat the ids in author_id as "or"
      #   'true' - treat the ids in author_id as "and" (only Sources with all and only all will match)
      attr_accessor :author_id_or

      # @params author [Array of Integer, Topic#id]
      attr_accessor :topic_id

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
      attr_accessor :serial_id

      # @return [Protonym.id, nil]
      #   return all sources in Citations linked to this name (or descendants option)
      #   to this TaxonName
      attr_accessor :taxon_name_id
      attr_accessor :descendants

      # @return [Boolean]
      # @params citations_on_otus ['false', 'true']
      #   ignored if taxon_name_id is not provided; if true then also include sources linked to OTUs that are in the scope of taxon_name_id
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
      def initialize(query_params)
        super

        @author = params[:author]
        @author_id = params[:author_id]
        @author_id_or =  boolean_param(params,:author_id_or)
        @bibtex_type = params[:bibtex_type]
        @citation_object_type = params[:citation_object_type]
        @citations = boolean_param(params,:citations) # TODO: rename coming to reflect conflict with Citations concern
        @citations_on_otus = boolean_param(params,:citations_on_otus)
        @descendants = boolean_param(params, :descendants)
        @documents = boolean_param(params,:documents)
        @exact_author = boolean_param(params,:exact_author)
        @exact_title = boolean_param(params,:exact_title)
        @in_project = boolean_param(params,:in_project)
        @nomenclature = boolean_param(params,:nomenclature)
        @query_string = params[:query_term]&.delete("\u0000") # TODO: likely remove with current permit() paradigm
        @roles = boolean_param(params,:roles)
        @serial = boolean_param(params,:serial)
        @serial_id = params[:serial_id]
        @source_id = params[:source_id]
        @source_type = params[:source_type]
        @taxon_name_id = params[:taxon_name_id]
        @title = params[:title]
        @topic_id = params[:topic_id]
        @with_doi = boolean_param(params, :with_doi)
        @with_title = boolean_param(params, :with_title)
        @year_end = params[:year_end]
        @year_start = params[:year_start]

        build_terms

        set_data_attributes_params(params)
        set_attributes_params(params)
        set_empty_params(params)
        set_tags_params(params)
        set_notes_params(params)
        set_user_dates(params)
      end

      def source_id
        [@source_id].flatten.compact.uniq
      end

      def serial_id
        [@serial_id].flatten.compact.uniq
      end

      def topic_id
        [@topic_id].flatten.compact.uniq
      end

      def citation_object_type
        [@citation_object_type].flatten.compact.uniq
      end

      def author_id
        [@author_id].flatten.compact.uniq
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
        table[:type].eq('Source::Bibtex').and(table[:bibtex_type].in(bibtex_type))
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact
      end

      # Return all citations on Taxon names and descendants,
      # and optionally OTUs.
      def taxon_name_id_facet
        return nil if taxon_name_id.empty?

        joins = [
          ancestor_taxon_names_join,
          ancestor_taxon_name_classifications_join,
          ancestor_taxon_name_relationship_join(:subject_taxon_name_id),
          ancestor_taxon_name_relationship_join(:object_taxon_name_id)
        ]

        joins.push ancestor_otus_join if citations_on_otus

        union = joins.collect{|j| '(' + ::Source.joins(:citations).joins( j.join_sources).to_sql + ')'}.join(' UNION ')

        ::Source.from("( #{union} ) as sources").distinct
      end

      def source_type_facet
        return nil if source_type.blank?
        table[:type].eq(source_type)
      end

      def year_facet
        return nil if year_start.blank?
        if year_start && year_end.present?
          table[:year].gteq(year_start)
            .and(table[:year].lteq(year_end))
        else # only start
          table[:year].eq(year_start)
        end
      end

      def serial_id_facet
        serial_id.empty? ? nil : table[:serial_id].in(serial_id)
      end

      def author_id_facet
        return nil if author_id.empty?
        o = table
        r = ::Role.arel_table

        a = o.alias('a_')
        b = o.project(a[Arel.star]).from(a)

        c = r.alias('r1')

        b = b.join(c, Arel::Nodes::OuterJoin)
          .on(
            a[:id].eq(c[:role_object_id])
          .and(c[:role_object_type].eq('Source'))
          .and(c[:type].eq('SourceAuthor'))
          )

        e = c[:id].not_eq(nil)
        f = c[:person_id].in(author_id)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.having(a['id'].count.eq(author_id.length)) unless author_id_or
        b = b.as('aut_z1_')

        ::Source.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id'])))).distinct
      end

      def topic_id_facet
        return nil if topic_id.empty?
        ::Source.joins(:citation_topics).where(citation_topics: { topic_id:}).distinct
      end

      def in_project_facet
        return nil if project_id.empty? || in_project.nil?

        if in_project
          ::Source.joins(:project_sources)
            .where(project_sources: {project_id:})
        else
          ::Source.left_outer_joins(:project_sources)
            .where('project_sources.project_id != ? OR project_sources.id IS NULL', project_id) # TODO: probably project_id
            .distinct
        end
      end

      # Over-rides Query::Filter identifier_type_facet to handle with_doi exception
      def identifier_type_facet
        return nil if identifier_type.empty? || with_doi
        q = referenced_klass.joins(:identifiers)
        w = identifier_table[:type].in(identifier_type)
        q.where(w).distinct
      end

      # TODO: move to generalized code in Identifiers concern
      def with_doi_facet
        return nil if with_doi.nil?
        if with_doi
          ::Source.joins(:identifiers).where(identifiers: {type: 'Identifier::Global::Doi'}).distinct
        else
          ::Source.left_outer_joins(:identifiers).where("(identifiers.type != 'Identifier::Global::Doi') OR (identifiers.identifier_object_id is null)").distinct
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
            .where(roles: {id: nil}).distinct
        end
      end

      # TODO: move to a concern
      def document_facet
        return nil if documents.nil?

        if documents
          ::Source.joins(:documents, :project_sources).where(project_sources: {project_id:}).distinct
        else
          a = ::Source.where.missing(:documents).distinct
          b = ::Source.joins(:project_sources).where(project_sources: {project_id: }).where.missing(:documentation).distinct

          ::Source.from("((#{a.to_sql}) UNION (#{b.to_sql})) as sources")
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
          .where(citations: {citation_object_type:}).distinct
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

      def citations_facet
        return nil if citations.nil?
        if citations
          ::Source.joins(:citations).distinct
        else
          ::Source.where.missing(:citations).distinct
        end
      end

      # Over-ride the inclusion of this facet at the Filter level.
      def project_id_facet
        nil
      end

      def query_facets_facet(name = nil)
        return nil if name.nil?

        q = send((name + '_query').to_sym)

        return nil if q.nil?

        n = "query_#{name}_src"

        s = "WITH #{n} AS (" + q.all.to_sql + ') ' +
          ::Source
          .joins(:citations)
          .joins("JOIN #{n} as #{n}1 on citations.citation_object_id = #{n}1.id AND citations.citation_object_type = '#{name.treetop_camelize}'")
          .to_sql

        ::Source.from('(' + s + ') as sources').distinct
      end

      def merge_clauses
        s = ::Queries::Query::Filter::SUBQUERIES.select{|k,v| v.include?(:source)}.keys.map(&:to_s)
        [
          *s.collect{|m| query_facets_facet(m)}, # Reference all the Source referencing SUBQUERIES
          author_id_facet,
          citation_object_type_facet,
          citations_facet,
          document_facet,
          empty_fields_facet, # See Queries::Concerns::Empty
          in_project_facet,
          nomenclature_facet,
          not_empty_fields_facet,
          role_facet,
          taxon_name_id_facet,
          topic_id_facet,
          with_doi_facet,
        ]
      end

      def and_clauses
        [
          attribute_exact_facet(:author),
          attribute_exact_facet(:title),
          bibtex_type_facet,
          cached_facet,
          serial_facet,
          serial_id_facet,
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
          o[:taxon_name_id].eq(h[:descendant_id]).and(h[:ancestor_id].in(taxon_name_id))
        )
      end

      def ancestor_taxon_names_join
        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonName.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonName'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[:id].eq(h[:descendant_id]).and(h[:ancestor_id].in(taxon_name_id))
        )
      end

      def ancestor_taxon_name_classifications_join
        return nil if taxon_name_id.nil?

        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonNameClassification.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonNameClassification'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[:taxon_name_id].eq(h[:descendant_id]).and(h[:ancestor_id].in(taxon_name_id))
        )
      end

      def ancestor_taxon_name_relationship_join(join_on = :subject_taxon_name_id)
        return nil if taxon_name_id.nil?

        h = Arel::Table.new(:taxon_name_hierarchies)
        c = ::Citation.arel_table
        t = ::TaxonNameRelationship.arel_table

        c.join(t, Arel::Nodes::InnerJoin).on(
          t[:id].eq(c[:citation_object_id]).and(c[:citation_object_type].eq('TaxonNameRelationship'))
        ).join(h, Arel::Nodes::InnerJoin).on(
          t[join_on].eq(h[:descendant_id]).and(h[:ancestor_id].in(taxon_name_id))
        )
      end

    end
  end
end
