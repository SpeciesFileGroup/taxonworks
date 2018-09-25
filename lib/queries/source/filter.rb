module Queries
  module Source
    class Filter < Queries::Query

      attr_accessor :author_ids

      # @param [Hash] params
      def initialize(params)
        @query_string = params[:query_term]
        @project_id = params[:project_id]
        @author_ids = params[:author_ids] || []
        build_terms
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

      # @return [ActiveRecord::Relation]
      def all
        a = or_clauses
        b = merge_clauses
        if a && b
          b.where(a).distinct
        elsif a
          ::Source.where(a).distinct
        elsif b
          b.distinct
        else
          ::Source.all
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

    end
  end
end
