module Queries
  module Note 

    # !! does not inherit from base query
    class Filter 

      # General annotator options handling 
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to Note 
      attr_accessor :text

      def initialize(params)
        @text = params[:text]
        @options = params.permit(:created_after, :created_before, on: [], by: [], id: []) 
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          Queries::Annotator.annotator_params(options, ::Note),
          matching_text,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_text
        text.blank? ? nil : table[:text].eq(text) 
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Note.where(and_clauses)
        else
          ::Note.none
        end
      end

      # @return [Arel::Table]
      def table
        ::Note.arel_table
      end
    end
  end
end
