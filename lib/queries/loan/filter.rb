module Queries
  module Loan
    class Filter < Query::Filter
      include Queries::Helpers
      include Queries::Concerns::Tags
      include Queries::Concerns::Notes

      ATTRIBUTES = ::Loan.core_attributes.map(&:to_sym).freeze

      PARAMS = [
        *ATTRIBUTES,
        :descendants,
        :documentation, # TODO: concern?
        :loan_item_disposition,
        :loan_wildcards,
        :overdue,
        :person_id,
        :role,
        :taxon_name_id,
        :loan_id,

        :start_date_requested,           
        :start_date_sent,           
        :start_date_received,       
        :start_date_return_expected,
        :start_date_closed,    

        :end_date_requested,
        :end_date_sent,           
        :end_date_received,       
        :end_date_return_expected,
        :end_date_closed,    


        loan_id: [],
        loan_wildcards: [],
        loan_item_disposition: [],
        person_id: [],
        role: [],
        taxon_name_id: [],
      ].freeze

      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      attr_accessor :loan_id

      # @return [Array, of Symbols]
      # @param loan_wildcards [String, Array]
      #   used with ATTRIBUTE variables, wildcard match if
      # variable name is contained in this list
      attr_accessor :loan_wildcards

      # @return [Boolean, nil]
      #   nil - all
      #   true - with Documentation
      #   false - without Documentation
      attr_accessor :documentation

      # @return [Boolean, nil]
      #   nil - all
      #   true - overdue
      #   false - not overdue
      attr_accessor :overdue

      # @return [Array]
      # @param Role [String, nil]
      #   LoanRecipient, LoanSupervisor
      # If none provided both returned.
      # Only applied when person_id is present
      attr_accessor :role

      # @return [Array]
      #   one per of Person#id
      # See also role
      attr_accessor :person_id

      # @return [Array]
      # @param loan_item_disposition [Array, String]
      #  Match all loans with loan items that have that disposition
      attr_accessor :loan_item_disposition

      attr_accessor :start_date_requested
      attr_accessor :start_date_sent
      attr_accessor :start_date_received
      attr_accessor :start_date_return_expected
      attr_accessor :start_date_closed

      attr_accessor :end_date_requested
      attr_accessor :end_date_sent
      attr_accessor :end_date_received
      attr_accessor :end_date_return_expected
      attr_accessor :end_date_closed

      # not done
      attr_accessor :taxon_name_id
      attr_accessor :descendants

      # @param [Hash] params
      def initialize(query_params)
        super

        @descendants = boolean_param(params, :descendants)
        @documentation = boolean_param(params, :documentation)
        @loan_id = params[:loan_id]
        @loan_item_disposition = params[:loan_item_disposition]
        @loan_wildcards = params[:loan_wildcards]
        @overdue = boolean_param(params, :overdue)
        @person_id = params[:person_id]
        @role = params[:role]
        @taxon_name_id = params[:taxon_name_id]

        @start_date_requested = params[:start_date_requested]           
        @start_date_sent = params[:start_date_sent]           
        @start_date_received = params[:start_date_received]
        @start_date_return_expected = params[:start_date_return_expected]
        @start_date_closed = params[:start_date_closed]    
        @end_date_requested = params[:end_date_requested]           
        @end_date_sent = params[:end_date_sent]           
        @end_date_received = params[:end_date_received]       
        @end_date_return_expected = params[:end_date_return_expected]
        @end_date_closed = params[:end_date_closed]

        set_attributes(params)
        set_notes_params(params)
        set_tags_params(params)
      end

      def role
        r = [@role].flatten.compact.uniq
        r.empty? ? ['LoanSupervisor', 'LoanRecipient'] : r
      end

      def loan_wildcards
        [@loan_wildcards].flatten.compact.uniq.map(&:to_sym)
      end

      def loan_id
        [@loan_id].flatten.compact.uniq
      end

      def person_id
        [@person_id].flatten.compact.uniq
      end

      def otu_id
        [@otu_id].flatten.compact.uniq
      end

      def loan_item_disposition
        [@loan_item_disposition].flatten.compact.uniq
      end

      # @return Array
      # TODO: refactor into Query::Filter
      # See also CollectingEvent filter
      def attribute_clauses
        c = []
        ATTRIBUTES.each do |a|
          if v = send(a)
            if v.present?
              if loan_wildcards.include?(a)
                c.push Arel::Nodes::NamedFunction.new('CAST', [table[a].as('TEXT')]).matches('%' + v + '%')
              else
                c.push table[a].eq(v)
              end
            end
          end
        end
        c
      end

      def date_requested_facet
        return nil if start_date_requested.nil? && end_date_requested.nil?
        s,e = [start_date_requested, end_date_requested].compact
        e = s if e.nil?
        ::Loan.where(date_requested: (s..e))
      end

      def date_sent_facet
        return nil if start_date_sent.nil? && end_date_sent.nil?
        s,e = [start_date_sent, end_date_sent].compact
        e = s if e.nil?
        ::Loan.where(date_sent: (s..e))
      end

      def date_received_facet
        return nil if start_date_received.nil? && end_date_received.nil?
        s,e = [start_date_received, end_date_received].compact
        e = s if e.nil?
        ::Loan.where(date_received: (s..e))
      end

      def date_return_expected_facet
        return nil if start_date_return_expected.nil? && end_date_return_expected.nil?
        s,e = [start_date_return_expected, end_date_return_expected].compact
        e = s if e.nil?
        ::Loan.where(date_return_expected: (s..e))
      end

      def date_closed_facet
        return nil if start_date_closed.nil? && end_date_closed.nil?
        s,e = [start_date_closed, end_date_closed].compact
        e = s if e.nil?
        ::Loan.where(date_closed: (s..e))
      end

      def overdue_facet
        return nil if overdue.nil?
        if overdue
          ::Loan.overdue
        else
          ::Loan.not_overdue
        end
      end

      def documentation_facet
        return nil if documentation.nil?
        if documentation
          ::Loan.joins(:documentation)
        else
          ::Loan.where.missing(:documentation)
        end
      end

      def loan_item_disposition_facet
        return nil if loan_item_disposition.empty?
        ::Loan.joins(:loan_items).where(loan_items: {disposition: loan_item_disposition})
      end

      def person_role_facet
        return nil if person_id.empty?
        ::Loan.joins(:roles).where(roles: {type: role, person_id: person_id})
      end

      def otu_query_facet
        return nil if otu_query.nil?
        s = 'WITH query_otu_loan AS (' + otu_query.all.to_sql + ') '

        a = ::Loan.joins(:loan_items)
          .joins("JOIN query_otu_loan as query_otu_loan1 on query_otu_loan1.id = loan_items.loan_item_object_id AND loan_items.loan_item_object_type = 'Otu'").to_sql

        # Consider position = 1
        b = ::Loan.joins(:loan_items)
          .joins("JOIN collection_objects co on co.id = loan_items.loan_item_object_id and loan_items.loan_item_object_type = 'CollectionObject'")
          .joins('JOIN taxon_determinations td on co.id = td.biological_collection_object_id')
          .joins('JOIN query_otu_loan as query_otu_loan2 ON query_otu_loan2.id = td.otu_id').to_sql

        s << ::Loan.from("((#{a}) UNION (#{b})) as loans").to_sql

        ::Loan.from('(' + s + ') as loans')
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_loan AS (' + collection_object_query.all.to_sql + ') '

        a = ::Loan.joins(:loan_items)
          .joins("JOIN query_co_loan as query_co_loan1 on query_co_loan1.id = loan_items.loan_item_object_id AND loan_items.loan_item_object_type = 'CollectionObject'").to_sql

        ::Loan.from('(' + s + ::Loan.from("(#{a}) as loans").to_sql + ') as loans' )
      end

      def and_clauses
        attribute_clauses
      end

      def merge_clauses
        [
          date_requested_facet,
          date_sent_facet,
          date_received_facet,
          date_return_expected_facet,
          date_closed_facet,

          collection_object_query_facet,
          documentation_facet,
          loan_item_disposition_facet,
          otu_query_facet,
          overdue_facet,
          person_role_facet,
        ]
      end

    end
  end
end

