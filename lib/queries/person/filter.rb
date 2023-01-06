module Queries
  module Person

    class Filter < Query::Filter
      include Queries::Concerns::Tags
      include Queries::Concerns::Users
      include Queries::Concerns::Notes
      include Queries::Concerns::DataAttributes

      # @return [String, nil]
      attr_accessor :active_after_year

      # @return [String, nil]
      attr_accessor :active_before_year

      # @return [String, nil]
      attr_accessor :born_after_year

      # @return [String, nil]
      attr_accessor :born_before_year

      # @return [String, nil]
      attr_accessor :died_after_year

      # @return [String, nil]
      attr_accessor :died_before_year

      # @return [Array]
      #   only return people with roles in this project(s) or roles through Sources in ProjectSources
      attr_accessor :except_project_id

      # @return [Array]
      #   values are attributes that should be wildcarded:
      #     last_name, first_name,  suffix, prefix, name
      #   When `name` then matches cached
      attr_accessor :exact

      # @param role [Array, String]
      #   A valid role name like 'Author' or array like ['TaxonDeterminer', 'SourceEditor'].  See Role descendants.
      # @return [Array]
      #   Exclude all People linked by this Role
      attr_accessor :except_role

      # @return [String, nil]
      #   also matches any AlternateValue
      attr_accessor :first_name

      # @return [String, nil]
      #   also matches any AlternateValue
      attr_accessor :last_name

      attr_accessor :last_name_starts_with

      # @return [Integer, nil]
      #   matches cached, records less than this edit distance are returned
      #   !! requires `name` or is ignored
      attr_accessor :levenshtein_cuttoff

      # @return [String, nil]
      #   where against `cached`
      attr_accessor :name

      # @return [String, nil]
      #   also matches any AlternateValue
      attr_accessor :prefix

      # @return [Array]
      #   only return people with roles in this project(s) or roles through Sources in ProjectSources
      attr_accessor :project_id

      # @return [String, nil]
      #   also matches any AlternateValue
      attr_accessor :suffix

      # @return [String, nil]
      #   a regular expression, Postgres compatible, matches against cached
      attr_accessor :regex

      # @return [String, nil]
      #   the number of times this name must be an identical match
      #   must be 2 or higher or will be ignored
      attr_accessor :repeated_total

      # @param role [Array, String]
      #   A valid role name like 'Author' or array like ['TaxonDeterminer', 'SourceEditor'].  See Role descendants.
      # @return [Array]
      attr_accessor :role

      # @return [String, nil]
      #   the maximum number of roles the Person must be in, further scoped to only counting `role` when provided
      attr_accessor :role_total_max

      # @return [String, nil]
      #   the minimum number of roles the Person must be in, further scoped to only counting `role` when provided
      attr_accessor :role_total_min

      # @return [Array]
      # @param with [Array of strings]
      #    legal values are first_name, prefix, suffix
      #    only return names where the field provided is not nil
      attr_accessor :with

      # @return [Array]
      # @param without [Array of strings]
      #    legal values are first_name, prefix, suffix
      #    only return names where the field provided is nil
      attr_accessor :without

      # @params params [ActionController::Parameters]
      def initialize(params = {})

        @role_total_min = params[:role_total_min]
        @role_total_max = params[:role_total_max]

        @role = params[:role]
        @except_role = params[:except_role]

        @first_name = params[:first_name]
        @last_name = params[:last_name]

        @name = params[:name]

        @with = params[:with]
        @without = params[:without]

        @last_name_starts_with = params[:last_name_starts_with]

        @exact = params[:exact]

        @project_id = params[:project_id]
        @except_project_id = params[:except_project_id]

        @levenshtein_cuttoff = params[:levenshtein_cuttoff]

        @regex = params[:regex]

        @born_after_year = params[:born_after_year]
        @born_before_year = params[:born_before_year]

        @active_after_year = params[:active_after_year]
        @active_before_year = params[:active_before_year]

        @died_after_year = params[:died_after_year]
        @died_before_year = params[:died_before_year]

        @repeated_total = params[:repeated_total]

        set_data_attributes_params(params)
        set_notes_params(params)
        set_identifier(params)
        set_tags_params(params)
        set_user_dates(params)
      end

      def with
        [@with].flatten.compact
      end

      def without
        [@without].flatten.compact
      end

      def exact
        [@exact].flatten.compact
      end

      def role
        [@role].flatten.compact
      end

      def except_role
        [@except_role].flatten.compact
      end

      # @return [Arel::Table]
      def role_table
        ::Role.arel_table
      end

      def project_id
        [@project_id].flatten.compact
      end

      def except_project_id
        [@except_project_id].flatten.compact
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

        if exact.include?(part.to_s)
          w = '%' + v + '%'
          w1 = table[part].matches(w)
          w2 = a[:value].matches(w)
        else
          w1 = table[part].eq(v)
          w2 = a[:value].eq(v)
        end

        q.where( w1.or(w2).to_sql )
      end


      def regex_facet
        return nil if regex.blank?
        ::Person.where('cached ~* ?', regex)
      end

      def name_facet
        return nil if name.nil? || !levenshtein_cuttoff.blank?
        if exact.include?('name')
          table[:cached].eq(name)
        else
          table[:cached].matches('%' + name + '%')
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

      def except_role_facet
        return nil if except_role.empty?
        #  ::Person.left_outer_joins(:roles)
        #    .where( roles: {person_id: nil})
        #    .or( ::Person.left_outer_joins(:roles).where.not( role_table[:type].eq_any(except_role)) )
        #    .distinct

        # ::Person.joins("LEFT JOIN roles on roles.person_id = people.id AND roles.type IN (#{except_role.collect{|r| "'#{r}'"}.join(',')})")
        #   .where( roles: {id: nil})
        #   .distinct

        ::Person.joins(
          table.join(role_table, Arel::Nodes::OuterJoin).on(
            table[:id].eq(role_table[:person_id]).and(role_table[:type]).in(except_role)
          ).join_sources
        ).merge(
          ::Role.where(id: nil)
        )
      end

      def repeated_total_facet
        return nil if repeated_total.blank? || repeated_total.to_i < 2
        ::Person.where(
          cached: ::Person.select(:cached).group(:cached).having('COUNT(cached) > ?', repeated_total)
        )
      end

      def role_total_facet
        return nil if (role_total_min.blank? && role_total_max.blank?)
        min_max = [role_total_min&.to_i, role_total_max&.to_i ].compact

        q = ::Person.joins(:roles)
          .select('people.*, COUNT(roles.person_id)')
          .group('people.id, roles.person_id')
          .having("COUNT(roles.person_id) >= #{min_max[0]}")

        if !role.empty?
          q = q.where(role_table[:type].eq_any(role))
        end

        # Untested
        q = q.having("COUNT(roles.person_id) <= #{min_max[1]}") if min_max[1]

        q.distinct
      end

      def with_facet
        return nil if with.empty?
        a = with.shift
        q = table[a.to_sym].not_eq(nil)

        with.each do |f|
          q = q.and(table[f.to_sym].not_eq(nil))
        end
        q
      end

      def without_facet
        return nil if without.empty?
        a = without.shift
        q = table[a.to_sym].eq(nil)

        without.each do |f|
          q = q.and(table[f.to_sym].eq(nil))
        end
        q
      end

      def levenshtein_facet
        return nil unless levenshtein_cuttoff && (!name.blank?)
        ::Person.where(
          levenshtein_distance(:cached, name).lteq(levenshtein_cuttoff).to_sql
        )
      end

      def project_id_facet
        return nil unless !project_id.empty?

        w1 = role_table[:project_id].eq_any(project_id)
        w2 = ::ProjectSource.arel_table[:project_id].eq_any(project_id)

        a = ::Person.joins(:roles).where(w1.to_sql)
        b = ::Person.joins(sources: [:project_sources]).where( w2.to_sql)

        ::Person.from("((#{a.to_sql}) UNION (#{b.to_sql})) as people")
      end

      def except_project_id_facet
        return nil unless !except_project_id.empty?

        w1 = role_table[:project_id].not_eq_any(except_project_id)
        w2 = ::ProjectSource.arel_table[:project_id].not_eq_any(except_project_id)

        a = ::Person.joins(:roles).where(w1.to_sql)
        b = ::Person.joins(sources: [:project_sources]).where( w2.to_sql)

        ::Person.from("((#{a.to_sql}) UNION (#{b.to_sql})) as people")
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          with_facet,
          without_facet,
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
          name_part_facet(:suffix),
          name_part_facet(:prefix),

          role_total_facet,
          repeated_total_facet,
          regex_facet,

          except_role_facet,
          role_facet,
          levenshtein_facet,

          identifier_between_facet,
          identifier_facet,
          identifier_namespace_facet,
          match_identifiers_facet,

          note_text_facet,        # See Queries::Concerns::Notes
          notes_facet,

          data_attribute_predicate_facet,
          data_attribute_value_facet,
          data_attributes_facet,

          keyword_id_facet,
          tag_facet,

          project_id_facet,
          except_project_id_facet,

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
