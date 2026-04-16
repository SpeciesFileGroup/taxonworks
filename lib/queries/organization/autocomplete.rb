module Queries
  module Organization
    class Autocomplete < Query::Autocomplete
      # @return [Array]
      # @param limit_to_role [String, Array]
      #    any Role class, like `TaxonNameAuthor`, `SourceAuthor`, `SourceEditor`, `Collector`, etc.
      attr_accessor :role_type


      # @params string [String]
      # @params [Hash] args
      def initialize(string, **params)
        @role_type = params[:role_type]

        super
      end

      def role_type
        [@role_type].flatten.compact.uniq
      end

      # @return [Arel::Nodes::Equatity]
      def role_match
        roles_table[:type].in(role_type)
      end

      def autocomplete_name_wildcard_end
        return nil if query_string.length < 2
        base_query.where( table[:name].matches(query_string + '%').to_sql).limit(20)
      end

      # @return [Array]
      #   TODO: optimize limits
      def autocomplete
        queries = [
          autocomplete_identifier_cached_like,
          autocomplete_name_wildcard_end
        ]

        queries.compact!

        return [] if queries.nil?

        result = []
        queries.each do |q|
          if role_type.present?
            q = q.joins(:roles).where(role_match.to_sql)
          end
          result += q.to_a
          result.uniq!
          break if result.count > 39
        end
        result[0..39]
      end

    end
  end
end
