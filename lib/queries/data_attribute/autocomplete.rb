module Queries
  module DataAttribute
    class Autocomplete < Query::Autocomplete

      attr_accessor :term_key, :term_value

      # @param [Hash] args
      def initialize(string, project_id: nil)
        super
        set_key_value
      end

      # @return [Scope]
      def base_query
        ::DataAttribute.select('data_attributes.*')
      end

      def set_key_value
        @term_key, @term_value = query_string.split(' ')
      end

      def autocomplete_internal_exact_key_value
        return nil if term_value.nil? || term_key.nil?
        ::InternalAttribute.joins(:predicate).where(
          predicate_table[:name].eq(term_key).and(
            table[:value].eq(term_value))
        ).limit(20)
      end

      def autocomplete_import_exact_key_value
        return nil if term_value.nil? || term_key.nil?
        ::ImportAttribute.where(
          import_predicate: term_key, 
          value: term_value
        ).limit(20)
      end

      def autocomplete_internal_exact_key_wildcard_value
        return nil if term_value.nil? || term_key.nil?
        ::InternalAttribute.joins(:predicate).where(
          predicate_table[:name].eq(term_key).and(
            table[:value].matches('%' + term_value + '%'))
        ).limit(20)
      end

      def autocomplete_import_exact_key_wildcard_value
        return nil if term_value.nil? || term_key.nil?
        ::ImportAttribute.where(
          import_predicate: term_key, 
          value: '%' + term_value + '%'
        ).limit(20)
      end

      def autocomplete_internal_wildcard_key_value
        return nil if term_value.nil? || term_key.nil?
        ::InternalAttribute.joins(:predicate).where(
          predicate_table[:name].matches('%' + term_key + '%').and(
            table[:value].matches('%' + term_value + '%'))
        ).limit(20)
      end

      def autocomplete_import_wildcard_key_value
        return nil if term_value.nil? || term_key.nil?
        ::ImportAttribute.where(
          import_predicate: '%' + term_key + '%', 
          value: '%' + term_value + '%'
        ).limit(20)
      end

      # @return [Array]
      def autocomplete
        queries = [
          autocomplete_internal_exact_key_value,
          autocomplete_import_exact_key_value,
          autocomplete_internal_exact_key_wildcard_value,
          autocomplete_import_exact_key_wildcard_value,
          autocomplete_internal_wildcard_key_value,
          autocomplete_import_wildcard_key_value
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q ,i|
          a = q.where(with_project_id.to_sql) if project_id 
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 40 
        end
        result[0..40]
      end

      # @return [Arel::Table]
      def predicate_table
        ::Predicate.arel_table
      end

    end
  end
end
