module Queries
  module Loan
    class Filter < Query::Filter

      include Queries::Helpers

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes

      ATTRIBUTES = (::Loan.column_names - %w{project_id created_by_id updated_by_id created_at updated_at})

      # @params params ActionController::Parameters
      # @return ActionController::Parameters
      def self.base_params(params)
        params.permit(
          ATTRIBUTES, # Queries::CollectingEvent::Filter::ATTRIBUTES, # just ATTRIBUTES
          :loan_wildcards,
          :role,
          :person_id,
          :documentation, # TODO: concern?
          :overdue,
          :taxon_name_id,
          :descendants,
          :otu_id,
          :loan_item_disposition,
          
          loan_item_disposition: [],
          otu_id: [],
          taxon_name_id: [],
          person_id: [],
        )
      end

      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      # @return [Array]
      # @param loan_wildcards [String, Array]
      #   used with ATTRIBUTE variables, wildcard match if variable 
      # name is contained in this list
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
        @loan_wildcards = params[:loan_wildcards]
        @role = params[:role]
        @person_id = params[:person_id]
        @documentation = boolean_param(params, :documentation)
        @overdue = boolean_param(params, :overdue)
        @taxon_name_id = params[:taxon_name_id]
        @descendants = boolean_param(params, :descendants)
        @otu_id = params[:otu_id]
        @loan_item_disposition = params[:loan_item_disposition] 

        set_notes_params(params)
        set_tags_params(params)

        super
      end

      def role 
        [@role].flatten.compact.uniq
      end

      def loan_wildcards 
        [@loan_wildcards].flatten.compact.uniq
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
                c.push Arel::Nodes::NamedFunction.new('CAST', [table[a.to_sym].as('TEXT')]).matches('%' + v.to_s + '%')
              else
                c.push table[a.to_sym].eq(v)
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

      def base_and_clauses
        (attribute_clauses + 
          [ 
          
        ]).compact
      end

      def base_merge_clauses
        [ documentation_facet,
          overdue_facet,
          loan_item_disposition_facet,
        ].compact
      end

    end
  end
end

