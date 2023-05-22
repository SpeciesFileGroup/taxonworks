module Queries
  module Person

    class Autocomplete < Query::Autocomplete

      include Queries::Concerns::AlternateValues
      include Queries::Concerns::Tags

      # @return [Array]
      # @param limit_to_role [String, Array]
      #    any Role class, like `TaxonNameAuthor`, `SourceAuthor`, `SourceEditor`, `Collector`, etc.
      attr_accessor :role_type

      # @return [Boolean, nil]
      #   true - restrict to only people used in this project
      #   nil, false - ignored
      attr_accessor :in_project

      # gets project_id from Query::Autocomplete

      # @param [Hash] args
      def initialize(string, **params)
        @role_type = params[:role_type]
        @in_project = boolean_param(params, :in_project)

        # project_id is required!!

        set_tags_params(params)
        set_alternate_value(params)
        super
      end

      def role_type
        [@role_type].flatten.compact.uniq
      end

      # @return [Arel::Nodes::Equatity]
      def role_match
        a = roles_table[:type].eq_any(role_type)
        a = a.and(roles_table[:project_id].eq_any(project_id)) if in_project
        a
      end

      # @return [Scope]
      def autocomplete_exact_match
        a = normalize_name
        return nil if a.nil?
        base_query.where(
          table[:cached].eq(normalize_name).to_sql
        )
      end

      def autocomplete_exact_last_name_match
        base_query.where(
          table[:last_name].eq(query_string).to_sql
        )
      end

      # @return [Scope]
      def autocomplete_exact_inverted
        a = invert_name
        return nil if a.nil?
        base_query.where(
          table[:cached].eq(a).to_sql
        )
      end

      def autocomplete_alternate_values_last_name
        matching_alternate_value_on(:last_name)
      end

      def autocomplete_alternate_values_first_name
        matching_alternate_value_on(:first_name)
      end

      # TODO: Use bibtex parser!!
      # @param [String] string
      # @return [String, nil]
      def normalize(string)
        n = string.strip.split(/\s*\,\s*/, 2).join(', ')
        return nil unless n.include?(' ')
        n
      end

      # TODO: Use Namae?
      # @return [String] simple name inversion
      #   given `Sarah Smith` return `Smith, Sarah`
      def invert_name
        a = normalize( query_string.split(/\s+/, 2).reverse.map(&:strip).join(', ') )
        return nil if a.nil?
        a
      end

      # @return [String]
      def normalize_name
        a = normalize(query_string)
        return nil if a.nil?
        a
      end

      # @return [Array]
      def autocomplete
        return [] if query_string.blank? || project_id.empty?

        queries = [
          [ autocomplete_exact_id, false ],
          [ autocomplete_exact_match&.limit(5), true ],
          [ autocomplete_exact_inverted&.limit(5), true ],
          [ autocomplete_identifier_cached_exact, false ],
          [ autocomplete_identifier_identifier_exact, false ],
          [ autocomplete_exact_last_name_match.limit(20), true ],
          [ autocomplete_alternate_values_last_name.limit(20), true ],
          [ autocomplete_alternate_values_first_name.limit(20), true ],
          [ autocomplete_ordered_wildcard_pieces_in_cached&.limit(5), true ],
          [ autocomplete_cached_wildcard_anywhere&.limit(20), true ], # in Queries::Query::Autocomplete
          [ autocomplete_cached, true ]
        ]

        queries.compact!

        updated_queries = []

        pr_id = project_id.join(',') if project_id
        queries.each_with_index do |q, i|
          a = q[0]

          if !a.nil?
            if role_type.present?
              a = a.joins(:roles).where(role_match.to_sql)
            end

            if q[1] # do not use extended query for identifiers
              if project_id.present?
                a = a.left_outer_joins(:roles)
                .joins("LEFT OUTER JOIN sources ON roles.role_object_id = sources.id AND roles.role_object_type = 'Source'")
                .joins('LEFT OUTER JOIN project_sources ON sources.id = project_sources.source_id')
                .select("people.*, COUNT(roles.id) AS use_count, CASE WHEN roles.project_id IN (#{pr_id}) THEN roles.project_id WHEN project_sources.project_id IN (#{pr_id}) THEN project_sources.project_id ELSE NULL END AS in_project")
                .group('people.id, roles.project_id, project_sources.project_id')
                .order('in_project, use_count DESC')
                #a = a.left_outer_joins(:roles)
                #     .joins("LEFT OUTER JOIN sources ON roles.role_object_id = sources.id AND roles.role_object_type = 'Source'")
                #     .joins('LEFT OUTER JOIN project_sources ON sources.id = project_sources.source_id')
                #     .select("people.*, COUNT(roles.id) AS use_count, CASE WHEN MAX(roles.project_id) IN (#{pr_id}) THEN MAX(roles.project_id) WHEN MAX(project_sources.project_id) IN (#{pr_id}) THEN MAX(project_sources.project_id) ELSE NULL END AS in_project")
                #     .where("roles.project_id IN (#{pr_id}) OR project_sources.project_id IN (#{pr_id}) OR ( (roles.project_id NOT IN (#{pr_id}) OR roles.project_id IS NULL) AND (project_sources.project_id NOT IN (#{pr_id}) OR project_sources.project_id IS NULL))")
                #     .group('people.id')
                #     .order('in_project, use_count DESC')
              end
            end
          end
          updated_queries[i] = a
        end
        result = []
        updated_queries.compact!
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result = result[0..19]
      end

      # @return [Arel::Table]
      def roles_table
        ::Role.arel_table
      end
    end
  end
end
