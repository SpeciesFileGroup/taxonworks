module Queries
  module Source
    class Filter < Queries::Query

      include Queries::Concerns::Tags

      # @project_id from Queries::Query
      #   if provided then only Sources in this project are returned

      # @query_term from Queries::Query

      # @return author [String, nil]
      #   !! matches `cached_author`
      attr_accessor :author 

      # @return [Boolean, nil]
      # @params exact_author ['true', 'false', nil]
      attr_accessor :exact_author 

      # @params author [Array of Integer, Person#id]
      attr_accessor :author_ids

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
      # @params roles ['true', 'false', nil]
      attr_accessor :roles

      # @return [Boolean, nil]
      # @params documentation ['true', 'false', nil]
      attr_accessor :documentation

      # @return [Boolean, nil]
      # @params nomenclature ['true', 'false', nil]
      attr_accessor :nomenclature

      # @return [Boolean, nil]
      # @params with_doi ['true', 'false', nil]
      attr_accessor :with_doi

      # @return [Array, nil]
      # @params citation_object_type  [Array of ObjectType]
      attr_accessor :citation_object_type

      # @return [Boolean, nil]
      # @params tags ['true', 'false', nil]
      attr_accessor :tags

      # @return [Boolean, nil]
      # @params notes ['true', 'false', nil]
      attr_accessor :notes

      # TODO: deprecate
      attr_accessor :recent

      # @param [Hash] params
      def initialize(params)
        @query_string = params[:query_term]
        @project_id = params[:project_id]
        @author_ids = params[:author_ids] || []
        @recent = params[:recent].blank? ? nil : true 
        build_terms
        set_identifier(params)
        set_tag
      end

      # @return [ActiveRecord::Relation]
      def or_clauses
        clauses = [
          only_ids,               # only intgers provided
          cached,                 # should hit titles when provided alone, unfragmented string matches
          fragment_year_matches   # keyword style ANDs years
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.or(b)
        end
        a
      end

      def merge_clauses
        clauses = [
          matching_author_id,
          # matching_verbatim_author
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [String]
      def where_sql
        return ::Source.none if or_clauses.nil?
        or_clauses.to_sql
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
  
      def matching_author_id
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
        )

        e = c[:id].not_eq(nil)
        f = c[:person_id].eq_any(author_ids)

        b = b.where(e.and(f))
        b = b.group(a['id'])
        b = b.as('z1_')

        ::Source.joins(Arel::Nodes::InnerJoin.new(b, Arel::Nodes::On.new(b['id'].eq(o['id']))))
      end

      # @return [ActiveRecord::Relation]
      def by_project_all
        ::Source.where(where_sql).limit(500).distinct.order(:cached).joins(:project_sources).where(member_of_project_id.to_sql)
      end

      # @return [Arel::Table]
      def table
        ::Source.arel_table
      end

      def role_table
        ::Role.arel_table
      end

      # @return [Arel::Table]
      def project_sources_table
        ::ProjectSource.arel_table
      end

      # @return [Arel::Nodes::Equatity]
      def member_of_project_id
        project_sources_table[:project_id].eq(project_id)
      end

      # @return [ActiveRecord::Relation]
      def all
        a = or_clauses
        b = merge_clauses
        q = nil
        if a && b
          q = b.where(a).distinct
        elsif a
          q = ::Source.where(a).distinct
        elsif b
          q = b.distinct
        else
          q = ::Source.all
        end
        q = q.order(updated_at: :desc) if recent
        q 
      end
     
    end
  end
end
