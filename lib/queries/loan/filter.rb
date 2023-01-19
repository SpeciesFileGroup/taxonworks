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
        :otu_id,
        :overdue,
        :person_id,
        :role,
        :taxon_name_id,

        loan_item_disposition: [],
        otu_id: [],
        person_id: [],
        taxon_name_id: [],
      ].freeze

      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

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

      attr_accessor :role

      attr_accessor :person_id

      attr_accessor :taxon_name_id

      attr_accessor :descendants

      attr_accessor :otu_id

      # @return [Array]
      # @param loan_item_disposition [Array, String]
      #  Match all loans with loan items that have that disposition
      attr_accessor :loan_item_disposition

      # @param [Hash] params
      def initialize(params)
        @descendants = boolean_param(params, :descendants)
        @documentation = boolean_param(params, :documentation)
        @loan_item_disposition = params[:loan_item_disposition]
        @loan_wildcards = params[:loan_wildcards]
        @otu_id = params[:otu_id]
        @overdue = boolean_param(params, :overdue)
        @person_id = params[:person_id]
        @role = params[:role]
        @taxon_name_id = params[:taxon_name_id]

        set_attributes(params)
        set_notes_params(params)
        set_tags_params(params)
        super
      end

      def role
        [@role].flatten.compact.uniq
      end

      def loan_wildcards
        [@loan_wildcards].flatten.compact.uniq.map(&:to_sym)
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

      def and_clauses
        attribute_clauses
      end

      def merge_clauses
        [ documentation_facet,
          overdue_facet,
          loan_item_disposition_facet,
        ]
      end

    end
  end
end

