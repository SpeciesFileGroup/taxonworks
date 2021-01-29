module Queries
  module Person

    class Filter < Queries::Query
      include Queries::Concerns::Tags
      include Queries::Concerns::Users

      # @return [String, nil]
      #   also matches any AlternateValue
      attr_accessor :first_name

      # @return [String, nil]
      #   also matches any AlternateValue 
      attr_accessor :last_name

      # @param role [Array, String]
      #   A valid role name like 'Author' or array like ['TaxonDeterminer', 'SourceEditor'].  See Role descendants.
      # @return [Array]
      attr_accessor :role

      # @return [String, nil]
      #   where against `cached`
      attr_accessor :name

      # @return [Integer, nil]
      #   matches cached, records less than this edit distance are returned
      #   !! requires `name` or is ignored
      #   !! if provided then last/first_name are ignored
      attr_accessor :levenshtein_cuttoff

      # @return [Array]
      #   values are attributes that should be wildcarded:
      #     last_name, first_name, name
      attr_accessor :person_wildcard

      attr_accessor :born_after_year
      attr_accessor :born_before_year

      attr_accessor :active_after_year
      attr_accessor :active_before_year

      attr_accessor :died_after_year
      attr_accessor :died_before_year

      attr_accessor :last_name_starts_with

      # @return [Array]
      #   only return people with roles in this project, named to clarify this has slightly
      #   different meaning for shared people than straight project_id
      attr_accessor :used_in_project_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @role = [params[:role]].flatten.compact

        @first_name = params[:first_name]
        @last_name = params[:last_name]

        @name = params[:name]

        @last_name_starts_with = params[:last_name_starts_with]

        @person_wildcard = [params[:person_wildcard]].flatten.compact

        @used_in_project_id = params[:used_in_project_id]

        @levenshtein_cuttoff = params[:levenshtein_cuttoff]

        @born_after_year = params[:born_after_year]
        @born_before_year = params[:born_before_year]

        @active_after_year = params[:active_after_year]
        @active_before_year = params[:active_before_year]

        @died_after_year = params[:died_after_year]
        @died_before_year = params[:died_before_year]

        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)
      end

      # @return [Arel::Table]
      def table
        ::Person.arel_table
      end

      # @return [Arel::Table]
      def role_table
        ::Role.arel_table
      end

      def base_query
        ::Person.select('people.*')
      end

      def used_in_project_id
        [@used_in_project_id].flatten.compact
      end

      def born_after_year_facet
        return nil if born_after_year.nil?
        table[:year_born].gt(born_after_year)
      end

      def born_before_year_facet
        return nil if born_before_year.nil?
        table[:year_born].lt(born_before_year)
      end

      def died_after_year_facet
        return nil if died_after_year.nil?
        table[:year_died].gt(died_after_year)
      end

      def died_before_year_facet
        return nil if died_before_year.nil?
        table[:year_died].lt(died_before_year)
      end

      def active_after_year_facet
        return nil if active_after_year.nil?
        table[:year_active_start].gt(active_after_year)
          .or(table[:year_active_end].gt(active_after_year))
      end

      def active_before_year_facet
        return nil if active_before_year.nil?
        table[:year_active_start].lt(active_before_year)
          .or(table[:year_active_end].lt(active_before_year))
      end

      def name_part_facet(part = :last_name)
        v = send(part)

        return nil if v.nil?

        q = ::Person.left_outer_joins(:alternate_values)
        a = ::AlternateValue.arel_table

        w1, w2 = nil, nil

        if person_wildcard.include?(part.to_s)
          w = '%' + v + '%'
          w1 = table[part].matches(w)
          w2 = a[:value].matches(w)
        else
          w1 = table[part].eq(v)
          w2 = a[:value].eq(v)
        end

        q.where( w1.or(w2).to_sql )
      end

      def name_facet
        return nil if name.nil? || !levenshtein_cuttoff.blank?
        if person_wildcard.include?('name')
          table[:cached].matches('%' + name + '%')
        else
          table[:cached].eq(name)
        end
      end

      def last_name_starts_with_facet
        return nil if last_name_starts_with.blank? || !levenshtein_cuttoff.blank?
        table[:last_name].matches(last_name_starts_with + '%')
      end

      def role_facet
        return nil if role.empty?
        ::Person.joins(:roles).where( role_table[:type].eq_any(role) )
      end

      def levenshtein_facet
        return nil unless levenshtein_cuttoff && (!name.blank?)
        ::Person.where(
          levenshtein_distance(:cached, name).lt(levenshtein_cuttoff).to_sql
        )
      end

      def used_in_project_id_facet
        return nil unless !used_in_project_id.empty?

        w1 = role_table[:project_id].eq_any(used_in_project_id)
        w2 = ::ProjectSource.arel_table[:project_id].eq_any(used_in_project_id)

        a = ::Person.joins(:roles).where(w1.to_sql)
        b = ::Person.joins(sources: [:project_sources]).where( w2.to_sql)

        ::Person.from("((#{a.to_sql}) UNION (#{b.to_sql})) as people")
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          name_facet,
          born_after_year_facet,
          born_before_year_facet,

          died_after_year_facet,
          died_before_year_facet,

          active_after_year_facet,
          active_before_year_facet,

          last_name_starts_with_facet,
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
          name_part_facet(:last_name),
          name_part_facet(:first_name),

          role_facet,
          levenshtein_facet,

          identifier_between_facet,
          identifier_facet,
          identifier_namespace_facet,

          matching_keyword_ids,
          tag_facet,

          used_in_project_id_facet,

          created_updated_facet, # See Queries::Concerns::Users
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

        if a && b
          b.where(a).distinct
        elsif a
          ::Person.where(a).distinct
        elsif b
          b.distinct
        else
          ::Person.all
        end
      end
    end
  end
end
