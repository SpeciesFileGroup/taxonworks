module Queries
  module Person
    class Filter

      # - use similar/identical methods in IsData

      attr_accessor :limit_to_roles
      attr_accessor :first_name, :last_name
      attr_accessor :last_name_starts_with

      # @params params [ActionController::Parameters]
      def initialize(params)
        @limit_to_roles = params[:roles]
        @limit_to_roles ||= [] 
        @first_name = params[:first_name]
        @last_name = params[:last_name]
        @last_name_starts_with = params[:last_name_starts_with]
      end

      # @return [Arel::Table]
      def table
        ::Person.arel_table
      end

      # @return [Arel::Table]
      def roles_table
        ::Role.arel_table
      end

      def match_last_name
        last_name.nil? ? nil : table[:last_name].matches('%' + last_name + '%')
      end

      def match_start_of_last_name
        last_name_starts_with.nil? ? nil : table[:last_name].matches(last_name_starts_with + '%')
      end

      def match_first_name
        first_name.nil? ? nil : table[:first_name].matches('%' + first_name + '%')
      end

      def match_roles
        limit_to_roles.empty? ? nil : roles_table[:type].eq_any(limit_to_roles)
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          match_first_name,
          match_last_name,
          match_roles,
          match_start_of_last_name
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if c = and_clauses
          ::Person.includes(:roles).where(and_clauses.to_sql).references(:roles).distinct
        else
          ::Person.none
        end
      end

    end
  end
end
