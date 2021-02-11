module Queries
  module Source
    class Filter < Queries::Query

      # TODO: likely move to model (replicated in Source too)
      # Params exists for all CollectingEvent attributes except these
      ATTRIBUTES = (::Source.column_names - %w{id project_id created_by_id updated_by_id created_at updated_at cached})
      #  ATTRIBUTES.each do |a|
      #    class_eval { attr_accessor a.to_sym }
      #  end

      include Queries::Concerns::Tags
      include Queries::Concerns::Users
      include Queries::Concerns::Empty

      # @project_id from Queries::Query
      #   used in context of in_project when provided
      #   must also include `in_project=true|false`

      # @return [Boolean, nil]
      # @params in_project ['true', 'false', nil]
      # ! requires `project_id`
      attr_accessor :in_project

      # @return author [String, nil]
      attr_accessor :author 

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

      # @return [Boolean, nil]
      # @params notes ['true', 'false', nil]
      attr_accessor :notes

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

      # @param [Hash] params
      def initialize(params)
        @query_string = params[:query_term]
        
        @author = params[:author]
        @author_ids = params[:author_ids] || []

        @author_ids_or = (params[:author_ids_or]&.downcase == 'true' ? true : false) if !params[:author_ids_or].nil?

        @ids = params[:ids] || []
        @topic_ids = params[:topic_ids] || []
        @serial_ids = params[:serial_ids] || []
        @citation_object_type = params[:citation_object_type] || []
        @citations = (params[:citations]&.downcase == 'true' ? true : false) if !params[:citations].nil?
        @documents = (params[:documents]&.downcase == 'true' ? true : false) if !params[:documents].nil?
        @exact_author = (params[:exact_author]&.downcase == 'true' ? true : false) if !params[:exact_author].nil?
        @exact_title = (params[:exact_title]&.downcase == 'true' ? true : false) if !params[:exact_title].nil?
        @in_project = (params[:in_project]&.downcase == 'true' ? true : false) if !params[:in_project].nil?
        @nomenclature = (params[:nomenclature]&.downcase == 'true' ? true : false) if !params[:nomenclature].nil?
        @notes = (params[:notes]&.downcase == 'true' ? true : false) if !params[:notes].nil?
        @project_id = params[:project_id] # TODO: also in Queries::Query
        @roles = (params[:roles]&.downcase == 'true' ? true : false) if !params[:roles].nil?
        @source_type = params[:source_type]
        @title = params[:title]
        @with_doi = (params[:with_doi]&.downcase == 'true' ? true : false) if !params[:with_doi].nil?
        @year_end = params[:year_end]
        @year_start = params[:year_start]
        @recent = (params[:recent]&.downcase == 'true' ? true : false) if !params[:recent].nil?

        @citations_on_otus = (params[:citations_on_otus]&.downcase == 'true' ? true : false) if !params[:citations_on_otus].nil?
        @ancestor_id = params[:ancestor_id]

        build_terms
        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)

        set_empty_params(params)
      end

      # @return [Arel::Table]
      def table
        ::Source.arel_table
      end

      # @return [Arel::Table]
      def project_sources_table
        ::ProjectSource.arel_table
      end
 
      def base_query
        ::Source.select('sources.*')
      end

      # @return [ActiveRecord::Relation, nil]
      #   if user provides 5 or fewer strings and any number of years look for any string && year
      def fragment_year_matches
        if fragments.any?
          s = table[:cached].matches_any(fragments)
          s = s.and(table[:year].eq_any(years)) if !years.empty?
          s
        else
          nil
        end
      end

      # Return all citations on Taxon names and descendants,
      # and optionally OTUs.
      #
      # Slighly janky, will need to ultimately be extended,
      # at that time likely switch to UNION
      def ancestors_facet
        return nil if ancestor_id.nil?

        h = Arel::Table.new(:taxon_name_hierarchies)
        h1 = h.alias('ho_')

        c = ::Citation.arel_table
        c1 = c.alias('hoc_')

        o = ::Otu.arel_table

        s = table.alias('saf')

        select = [ 
          s[:id].as('source_id'),
          c[:id].as('c_id'),
          h[:ancestor_id].as('h_anc_id'),
        ]

        if citations_on_otus
          select += [
            c1[:id].as('c1_id'),
            h1[:ancestor_id].as('h1_anc_id')
          ] 
        end

        q = table.project(*select).from(s)

        # On taxon names
        q = q.join(c, Arel::Nodes::OuterJoin).on(
          s[:id].eq(c[:source_id]).and(c[:citation_object_type].eq('TaxonName'))
        ).join( h, Arel::Nodes::OuterJoin).on(
          c[:citation_object_id].eq(h[:descendant_id])
        )

        if citations_on_otus
          q = q.join(c1, Arel::Nodes::OuterJoin).on(
            s[:id].eq(c1[:source_id]).and(c1[:citation_object_type].eq('Otu'))
          ).join(o, Arel::Nodes::OuterJoin).on(
            o[:id].eq(c1[:citation_object_id])
          ).join(h1, Arel::Nodes::OuterJoin).on(
            o[:taxon_name_id].eq(h1[:descendant_id])
          )
        end

        # puts ::Source.connection.execute(q.to_sql).to_a

        q = q.as('source1')

        w = ( q[:h_anc_id].eq(ancestor_id).and(q[:c_id].not_eq(nil)) )

        if citations_on_otus
          w = w.or( q[:h1_anc_id].eq(ancestor_id).and( q[:c1_id].not_eq(nil) ))
        end

        ::Source.joins(Arel::Nodes::InnerJoin.new(q, Arel::Nodes::On.new(q[:source_id].eq(table[:id]))))
          .where(w)
          .distinct
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
        b = b.as('z1_')

        ::Source.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      def topic_ids_facet
        ::Source.joins(:citation_topics).where(citation_topics: { topic_id: topic_ids }).distinct unless topic_ids.empty?
      end

      def in_project_facet
        return nil if project_id.nil? || in_project.nil?

        if in_project
          ::Source.joins(:project_sources)
            .where(project_sources: {project_id: project_id})
        else
          ::Source.left_outer_joins(:project_sources)
            .where("project_sources.project_id != ? OR project_sources.id IS NULL", Current.project_id)
            .distinct
        end
      end

      # TODO: move to a concern
      def citation_facet
        return nil if citations.nil?

        if citations
          ::Source.joins(:citations).distinct
        else
          ::Source.left_outer_joins(:citations)
            .where(citations: {id: nil})
            .distinct
        end
      end

      # TODO: move to generalized code in identifiers concern
      def with_doi_facet
        return nil if with_doi.nil?

        # See lib/queries/concerns/identifiers.rb
        @identifier_type.push 'Identifier::Global::Doi'
        @identifier_type.uniq!

        if with_doi
          identifier_type_facet
        else
          ::Source.left_outer_joins(:identifiers)
            .where("(identifiers.type != 'Identifier::Global::Doi') OR (identifiers.identifier_object_id is null)")
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
      def note_facet
        return nil if notes.nil?

        if notes 
          ::Source.joins(:notes).distinct
        else
          ::Source.left_outer_joins(:notes)
            .where(notes: {id: nil})
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

      # TODO: move to citation concern
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

      def merge_clauses
        clauses = [
          ancestors_facet,
          author_ids_facet,
          topic_ids_facet,
          citation_facet,
          citation_object_type_facet,
          document_facet,
          in_project_facet,
          nomenclature_facet,
          role_facet,
          with_doi_facet,
          matching_keyword_ids,
          tag_facet,
          note_facet,
          identifier_between_facet,
          identifier_facet,
          identifier_namespace_facet,
          created_updated_facet, # See Queries::Concerns::Users
          empty_fields_facet, # See Queries::Concerns::Empty
          not_empty_fields_facet,
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = []

        clauses += [
          cached,
          source_ids_facet,
          serial_ids_facet,
          attribute_exact_facet(:author),
          attribute_exact_facet(:title),
          source_type_facet,
          year_facet
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
        b = merge_clauses

        q = nil
        if a && b
          q = b.where(a)
        elsif a
          q = ::Source.where(a)
        elsif b
          q = b
        else
          q = ::Source.all
        end

        q = q.order(updated_at: :desc) if recent
        q
      end

    end
  end
end
