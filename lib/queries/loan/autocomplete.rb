# TaxonNameAutocompleteQuery
module Queries
  module Loan 
    class Autocomplete < Queries::Query

      # @param [Hash] args
      def initialize(string, project_id: nil)
        super
      end

      # @return [String]
      def where_sql
        with_project_id.and(or_and).to_sql
      end

      # @return [Array]
      def autocomplete
        return [] if query_string.blank?

        queries = [
          autocomplete_recipient_email,
          autocomplete_exact_date_sent,
          autocomplete_exact_date_requested,
          autocomplete_exact_date_received,
          autocomplete_exact_id,
          autocomplete_identifier_identifier_exact,
          autocomplete_identifier_cached_like,
          autocomplete_identifier_matching_cached_fragments_anywhere,
          autocomplete_by_role
        ]
        queries.compact!

        updated_queries = []
        queries.each_with_index do |q,i|
          a = q
          a = q.where(project_id: project_id) if project_id
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end

        result[0..40]
      end

      def autocomplete_recipient_email
        o = table[:recipient_email].matches('%' + query_string + '%')
        ::Loan.where(o.to_sql)
      end

      def autocomplete_exact_date_sent
        o = table[:date_sent].eq(query_string)
        ::Loan.where(o.to_sql)
      end

      def autocomplete_exact_date_requested
        o = table[:date_requested].eq(query_string)
        ::Loan.where(o.to_sql)
      end

      def autocomplete_exact_date_received
        o = table[:date_received].eq(query_string)
        ::Loan.where(o.to_sql)
      end

      def autocomplete_by_role
        r = ::Person.arel_table
        o = r[:cached].matches('%' + query_string + '%')
        ::Loan.joins(:people).where(roles: { type: ['LoanRecipient', 'LoanSupervisor']}).where(o.to_sql)
      end

    end
  end
end
