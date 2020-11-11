module Queries
  module Person

    class Filter

      # include Queries::Concerns::Identifiers
      # include Queries::Concerns::Tags
      # include Queries::Concerns::AlternateValues

      # - use similar/identical methods in IsData
      attr_accessor :limit_to_roles
      attr_accessor :first_name, :last_name
      attr_accessor :last_name_starts_with

      attr_accessor :levenshtein_cuttoff

      # @params params [ActionController::Parameters]
      def initialize(params)
        @limit_to_roles = params[:roles]
        @limit_to_roles ||= [] 
        @first_name = params[:first_name]
        @last_name = params[:last_name]
        @last_name_starts_with = params[:last_name_starts_with]
        @levenshtein_cuttoff = params[:levenshtein_cuttoff] || 4
       # set_alternate_value(params)
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
        last_name.blank? ? nil : table[:last_name].matches('%' + last_name + '%')
      end

      def match_start_of_last_name
        last_name_starts_with.blank? ? nil : table[:last_name].matches(last_name_starts_with + '%')
      end

      def match_first_name
        first_name.blank? ? nil : table[:first_name].matches('%' + first_name + '%')
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
          match_start_of_last_name,
       #  matching_alternate_value_on_values(:last_name, [last_name]),
       #  matching_alternate_value_on_values(:first_name, [first_name]),
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
          ::Person.all
        end
      end

      def levenshtein_similar
        clauses = []
        clauses.push levenshtein_distance(:last_name, last_name).lt(levenshtein_cuttoff) if !last_name.blank?
        clauses.push levenshtein_distance(:first_name, first_name).lt(levenshtein_cuttoff) if !first_name.blank?

        a = clauses.shift
        a = a.and(clauses.first) if clauses.any?

        ::Person.where(a.to_sql)
      end

      def levenshtein_distance(attribute, value)
        value = "'" + value.gsub(/'/, "''") + "'"
        a = ApplicationRecord.sanitize_sql(value) 
        Arel::Nodes::NamedFunction.new("levenshtein", [table[attribute], Arel::Nodes::SqlLiteral.new(a) ] )
      end

    end
  end
end
