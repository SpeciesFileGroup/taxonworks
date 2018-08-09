module Queries
  module Person
    class Filter

      attr_accessor :limit_to_roles
      attr_accessor :and_or
      attr_accessor :options

      # @params params [ActionController::Parameters]
      def initialize(params)
        @limit_to_roles = params[:roles]
        @limit_to_roles = [] if @limit_to_roles.blank?
        # params.delete(:roles)

        @and_or = 'or'
        
        @options = {}
        @options[:last_name] = params[:last_name]
        @options[:first_name] = params[:first_name]
        @options = @options.select{|_kee, val| val.present? }
      end

      # @return [Arel::Table]
      def roles_table
        ::Role.arel_table
      end

      # @return [Arel::Table]
      def people_table
        ::Person.arel_table
      end

      def base_query
        ::Person.select('people.*')
      end

      def role_match
        case and_or
          when 'or'
            a = roles_table[:type].eq_any(limit_to_roles)
          when 'and'
            a = roles_table[:type].eq_all(limit_to_roles)
        end
        # a = a.and(roles_table[:project_id].eq(project_id)) if !project_id.blank?
        a
      end

      # @return [Scope]
      def first_and_last_wild_match
        last_name = options[:last_name]
        first_name = options[:first_name]
        last_name = last_name.blank? ? '' : last_name.gsub('*', '%')
        first_name = first_name.blank? ? '' : first_name.gsub('*', '%')
        if first_name.blank?
          return base_query.where(people_table[:last_name].matches(last_name))
        end
        if last_name.blank?
          return base_query.where(people_table[:first_name].matches(first_name))
        end
        base_query.where(people_table[:first_name].matches(first_name)
                           .and(people_table[:last_name].matches(last_name)))
      end

      # ported from Queries::Person::Autocomplete
      # @return [Array]
      # NOTODO: finesse whitespace issues -- not empirically a big deal at this time
      def partial_complete
        queries = [
          first_and_last_wild_match
        ]

        queries.compact!

        updated_queries = []
        queries.each_with_index do |q, i|
          a = q.joins(:roles).where(role_match.to_sql) if limit_to_roles.any?
          a ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result # [0..19] - this will return more than 19 in some cases, is that the intent?
      end

      # @return [Array]
      def wild_or_exact
        q = first_and_last_wild_match

        if limit_to_roles.any?
          q = q.joins(:roles).where(role_match.to_sql)
        end
        q.distinct(:cached).order(:last_name).order(:first_name)
      end

      # @param [Array] terms contains Strings
      # @return [ActiveRecord::Relation, nil]
      #   cached matches full query string wildcarded
      def cached(terms)
        if terms.empty?
          nil
        else
          terms = terms.map { |s| [s + '%', '%' + s + '%'] }
          people_table[:id].matches_any(terms.flatten)
        end
      end

      # @return [ActiveRecord::Relation]
      def first_last_cached
        terms = [options[:last_name], options[:first_name]].compact
        a = cached(terms)
        return nil if a.nil?
        base_query.where(a.to_sql)
      end

      # @return [ActiveRecord::Relation]
      # def and_clauses
      #   clauses = [
      #     Queries::Person.person_params(options, ::Role)
      #   ].compact
      # 
      #   a = clauses.shift
      #   clauses.each do |b|
      #     a = a.and(b)
      #   end
      #   a
      # end

      # @return [ActiveRecord::Relation]
      def all
        if limit_to_roles.any?
          ::Person.where(options).with_role(limit_to_roles)
        else
          ::Person.where(options)
        end
      end
    end

    # @param [ActionController::Parameters] params
    # @param [ApplicationRecord subclass] klass
    # @return [Arel::Nodes]
    # def self.person_params(params, klass)
    #   t = klass.arel_table
    #   raise 'This isn\'t finished, or even known to be required.'
    # end
  end
end
