module Queries
  module Serial

    # !! does not inherit from base query
    class Filter << Query::Filter

      # Params specific to Note
      attr_accessor :name

      def initialize(params)
        @name = params[:name]
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_name,
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_name
        name.blank? ? nil : table[:name].eq(name)
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Serial.where(and_clauses.to_sql)
        else
          ::Serial.all
        end
      end

      # @return [Arel::Table]
      def table
        ::Serial.arel_table
      end
    end
  end
end
