module Queries
  module Loan
    class Filter < Query::Filter
      ATTRIBUTES = ::Loan.core_attributes.map(&:to_sym).freeze

      include Queries::Concerns::Attributes
      include Queries::Concerns::Notes
      include Queries::Concerns::Tags
      include Queries::Helpers

      PARAMS = [
        *ATTRIBUTES,
        :descendants,
        :documentation, # TODO: concern?
        :end_date_closed,
        :end_date_received,
        :end_date_requested,
        :end_date_return_expected,
        :end_date_sent,
        :loan_id,
        :loan_item_disposition,
        :overdue,
        :person_id,
        :role,
        :start_date_closed,
        :start_date_received,
        :start_date_requested,
        :start_date_return_expected,
        :start_date_sent,
        :taxon_name_id,
        :with_date_closed,
        :with_date_received,
        :with_date_requested,
        :with_date_return_expected,
        :with_date_sent,

        loan_id: [],
        loan_item_disposition: [],
        person_id: [],
        role: [],
        taxon_name_id: [],
      ].freeze

      # @return [Boolean, nil]
      attr_accessor :with_date_requested

      # @return [Boolean, nil]
      #   whether value is present
      attr_accessor :with_date_sent

      # @return [Boolean, nil]
      #   whether value is present
      attr_accessor :with_date_return_expected

      # @return [Boolean, nil]
      #   whether value is present
      attr_accessor :with_date_received

      # @return [Boolean, nil]
      #   whether value is present
      attr_accessor :with_date_closed

      attr_accessor :loan_id

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

      attr_accessor :end_date_closed
      attr_accessor :end_date_received
      attr_accessor :end_date_requested
      attr_accessor :end_date_return_expected
      attr_accessor :end_date_sent
      attr_accessor :start_date_closed
      attr_accessor :start_date_received
      attr_accessor :start_date_requested
      attr_accessor :start_date_return_expected
      attr_accessor :start_date_sent

      # not done
      attr_accessor :taxon_name_id
      attr_accessor :descendants

      # @param [Hash] params
      def initialize(query_params)
        super

        @descendants = boolean_param(params, :descendants)
        @documentation = boolean_param(params, :documentation)
        @end_date_closed = params[:end_date_closed]
        @end_date_received = params[:end_date_received]
        @end_date_requested = params[:end_date_requested]
        @end_date_return_expected = params[:end_date_return_expected]
        @end_date_sent = params[:end_date_sent]
        @loan_id = params[:loan_id]
        @loan_item_disposition = params[:loan_item_disposition]
        @overdue = boolean_param(params, :overdue)
        @person_id = params[:person_id]
        @role = params[:role]
        @start_date_closed = params[:start_date_closed]
        @start_date_received = params[:start_date_received]
        @start_date_requested = params[:start_date_requested]
        @start_date_return_expected = params[:start_date_return_expected]
        @start_date_sent = params[:start_date_sent]
        @taxon_name_id = params[:taxon_name_id]

        @with_date_closed = boolean_param(params, :with_date_closed)
        @with_date_received = boolean_param(params, :with_date_received)
        @with_date_requested = boolean_param(params, :with_date_requested)
        @with_date_return_expected = boolean_param(params, :with_date_return_expected)
        @with_date_sent = boolean_param(params, :with_date_sent)

        set_attributes_params(params)
        set_notes_params(params)
        set_tags_params(params)

      end

      def role
        r = [@role].flatten.compact.uniq
        r.empty? ? ['LoanSupervisor', 'LoanRecipient'] : r
      end

      def taxon_name_id
        [@taxon_name_id].flatten.compact.uniq
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

      def taxon_name_id_facet
        return nil if taxon_name_id.empty?
        a = ::Queries::CollectionObject::Filter.new(taxon_name_id:, descendants:)
        b = ::Queries::Otu::Filter.new(taxon_name_id:, descendants:)

        a.project_id = nil
        b.project_id = nil

        if a.all(true)
          a.project_id = project_id
          c = ::LoanItem.from('(' +
                              'WITH co_tn AS (' + a.all.to_sql + ') ' +
                              ::LoanItem.joins("JOIN co_tn AS co_tn1 on co_tn1.id = loan_items.loan_item_object_id AND loan_items.loan_item_object_type = 'CollectionObject'").to_sql +
                              ') as loan_items'
                             ).to_sql
        end

        if b.all(true)
          b.project_id = project_id
          d = ::LoanItem.from('(' +
                              'WITH otu_tn AS (' + b.all.to_sql + ') ' +
                              ::LoanItem.joins("JOIN otu_tn AS otu_tn1 on otu_tn1.id = loan_items.loan_item_object_id AND loan_items.loan_item_object_type = 'Otu'").to_sql +
                              ') as loan_items'
                             ).to_sql
        end

        e = ::LoanItem.from( '(' + [c,d].compact.join(' UNION ') + ') as loan_items').to_sql

        s = 'WITH items AS (' + e + ') ' + ::Loan.joins('JOIN items as items1 on items1.loan_id = loans.id').to_sql

        ::Loan.from("(#{s}) as loans").distinct
      end

      def date_requested_range_facet
        return nil if start_date_requested.nil? && end_date_requested.nil?
        s,e = [start_date_requested, end_date_requested].compact
        e = s if e.nil?
        ::Loan.where(date_requested: (s..e))
      end

      def date_sent_range_facet
        return nil if start_date_sent.nil? && end_date_sent.nil?
        s,e = [start_date_sent, end_date_sent].compact
        e = s if e.nil?
        ::Loan.where(date_sent: (s..e))
      end

      def date_received_range_facet
        return nil if start_date_received.nil? && end_date_received.nil?
        s,e = [start_date_received, end_date_received].compact
        e = s if e.nil?
        ::Loan.where(date_received: (s..e))
      end

      def date_return_expected_range_facet
        return nil if start_date_return_expected.nil? && end_date_return_expected.nil?
        s,e = [start_date_return_expected, end_date_return_expected].compact
        e = s if e.nil?
        ::Loan.where(date_return_expected: (s..e))
      end

      def date_closed_range_facet
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
        ::Loan.joins(:loan_items).where(loan_items: {disposition: loan_item_disposition}).distinct
      end

      def person_role_facet
        return nil if person_id.empty?
        ::Loan.joins(:roles).where(roles: {type: role, person_id:}).distinct
      end

      def  with_date_requested_facet
        return nil if with_date_requested.nil?
        if with_date_requested
          table[:date_requested].not_eq(nil)
        else
          table[:date_requested].eq(nil)
        end
      end

      def  with_date_sent_facet
        return nil if with_date_sent.nil?
        if with_date_sent
          table[:date_sent].not_eq(nil)
        else
          table[:date_sent].eq(nil)
        end
      end

      def with_date_return_expected_facet
        return nil if with_date_return_expected.nil?
        if with_date_return_expected
          table[:date_return_expected].not_eq(nil)
        else
          table[:date_return_expected].eq(nil)
        end
      end

      def with_date_received_facet
        return nil if with_date_received.nil?
        if with_date_received
          table[:date_received].not_eq(nil)
        else
          table[:date_received].eq(nil)
        end
      end

      def with_date_closed_facet
        return nil if with_date_closed.nil?
        if with_date_closed
          table[:date_closed].not_eq(nil)
        else
          table[:date_closed].eq(nil)
        end
      end

      def otu_query_facet
        return nil if otu_query.nil?
        s = 'WITH query_otu_loan AS (' + otu_query.all.to_sql + ') '

        a = ::Loan.joins(:loan_items)
          .joins("JOIN query_otu_loan as query_otu_loan1 on query_otu_loan1.id = loan_items.loan_item_object_id AND loan_items.loan_item_object_type = 'Otu'").to_sql

        # Consider position = 1
        b = ::Loan.joins(:loan_items)
          .joins("JOIN collection_objects co on co.id = loan_items.loan_item_object_id and loan_items.loan_item_object_type = 'CollectionObject'")
          .joins("JOIN taxon_determinations td on co.id = td.taxon_determination_object_id AND td.taxon_determination_object_type = 'CollectionObject'")
          .joins('JOIN query_otu_loan as query_otu_loan2 ON query_otu_loan2.id = td.otu_id').to_sql

        s << ::Loan.from("((#{a}) UNION (#{b})) as loans").to_sql

        ::Loan.from('(' + s + ') as loans').distinct
      end

      def collection_object_query_facet
        return nil if collection_object_query.nil?
        s = 'WITH query_co_loan AS (' + collection_object_query.all.to_sql + ') '

        a = ::Loan.joins(:loan_items)
          .joins("JOIN query_co_loan as query_co_loan1 on query_co_loan1.id = loan_items.loan_item_object_id AND loan_items.loan_item_object_type = 'CollectionObject'").to_sql

        ::Loan.from('(' + s + ::Loan.from("(#{a}) as loans").to_sql + ') as loans' ).distinct
      end

      def and_clauses
        [
          with_date_closed_facet,
          with_date_received_facet,
          with_date_requested_facet,
          with_date_return_expected_facet,
          with_date_sent_facet,
        ]
      end

      def merge_clauses
        [
          collection_object_query_facet,
          date_closed_range_facet,
          date_received_range_facet,
          date_requested_range_facet,
          date_return_expected_range_facet,
          date_sent_range_facet,
          documentation_facet,
          loan_item_disposition_facet,
          otu_query_facet,
          overdue_facet,
          person_role_facet,
          taxon_name_id_facet,
        ]
      end

    end
  end
end
