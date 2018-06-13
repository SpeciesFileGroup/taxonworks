module Queries
  module Person
    class Filter

      attr_accessor :limit_to_roles

      # @params params [ActionController::Parameters]
      def initialize(params)
        @limit_to_roles = params[:roles]
        @options = params
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
            Queries::Person.person_params(options, ::Role)
            ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Person.where(and_clauses)
        else
          ::Person.none
        end
      end

      # @return [Arel::Table]
      def table
        ::Person.arel_table
      end
    end
# @param [ActionController::Parameters] params
# @param [ApplicationRecord subclass] klass
# @return [Arel::Nodes]
    def self.person_params(params, klass)
      t = klass.arel_table
      raise 'This isn\'t finished, or even known to be required.'
    end
  end
end
