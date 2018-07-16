module Queries
  module Person
    class Filter

      attr_accessor :limit_to_roles
      attr_accessor :and_or
      attr_accessor :options

      # @params params [ActionController::Parameters]
      def initialize(params)
        @limit_to_roles = params[:roles]
        @limit_to_roles = [] if @limit_to_roles.nil?
        params.delete(:roles)
        @and_or               = 'or'
        @options              = {}
        @options[:last_name]  = params[:lastname]
        @options[:first_name] = params[:firstname]
        @options              = @options.select { |_kee, val| val.present? }
        @options
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
      def last_exact_match
        term = options[:last_name]
        if term.nil?
          nil
        else
          base_query.where(people_table[:last_name].eq(term).to_sql)
        end
      end

      # @return [Scope]
      def first_exact_match
        term = options[:first_name]
        if term.nil?
          nil
        else
          base_query.where(people_table[:first_name].eq(term).to_sql)
        end
      end

      # @return [Scope]
      def last_partial_match
        term = options[:last_name]
        if term.nil?
          nil
        else
          terms = '%' + term + '%'
          base_query.where(people_table[:last_name].matches(terms).to_sql)
        end
      end

      # @return [Scope]
      def first_partial_match
        term = options[:first_name]
        if term.nil?
          nil
        else
          terms = '%' + term + '%'
          base_query.where(people_table[:first_name].matches(terms).to_sql)
        end
      end

      def wildcard_complete
        grp = star_like(options[:last_name])
        grp << star_like(options[:first_name])

        grp = grp.flatten.collect { |piece| '%' + piece + '%' }

        queries = []

        grp.each_with_index { |q, _i|
          if limit_to_roles.any?
            a = base_query.where(people_table[:cached].matches(q))
                  .joins(:roles)
                  .where(role_match.to_sql)
          end
          a ||= base_query.where(people_table[:cached].matches(q))
          queries << a
        }
        queries
      end

      def last_wild_match
        grp = star_like(options[:last_name])
        grp = grp.flatten.collect { |piece| '%' + piece + '%' }

        queries = []

        grp.each_with_index { |q, _i|
          # if limit_to_roles.any?
          #   a = base_query.where(people_table[:last_name].matches(q))
          #         .joins(:roles)
          #         .where(role_match.to_sql)
          # end
          a ||= base_query.where(people_table[:last_name].matches(q))
          queries << a
        }
        queries
      end

      def first_wild_match
        grp = star_like(options[:first_name])
        grp = grp.flatten.collect { |piece| '%' + piece + '%' }

        queries = []

        grp.each_with_index { |q, _i|
          # if limit_to_roles.any?
          #   a = base_query.where(people_table[:first_name].matches(q))
          #         .joins(:roles)
          #         .where(role_match.to_sql)
          # end
          a ||= base_query.where(people_table[:first_name].matches(q))
          queries << a
        }
        queries
      end

      def first_and_last_wild_match
        base_query.where(last_wild_match).where(first_wild_match)
      end

      def star_like(term)
        return [] if term.nil?
        return [term] unless term.index('*')

        pieces = term.split('*')
        pieces.delete_if { |str| str.empty? }

      end

      # ported from Queries::Person::Autocomplete
      # @return [Array]
      def partial_complete
        queries = [
          last_partial_match,
          first_partial_match,
          last_exact_match,
          first_exact_match,
          last_wild_match.first,
          first_wild_match.first,
          # autocomplete_exact_inverted,
          # autocomplete_ordered_wildcard_pieces_in_cached,
          # autocomplete_cached_wildcard_anywhere, # in Queries::Query
          # first_last_cached
        ]

        # wild_set = last_wild_match
        # wild_set << first_wild_match
        # wild_set.each {|q| queries.push(q)}
        ## queries.push(last_wild_match.first)
        ## queries.push(first_wild_match.first)
        queries.compact!

        updated_queries = []
        queries.each_with_index do |q, i|
          a                  = q.joins(:roles).where(role_match.to_sql) if limit_to_roles.any?
          a                  ||= q
          updated_queries[i] = a
        end

        result = []
        updated_queries.each do |q|
          result += q.to_a
          result.uniq!
          break if result.count > 19
        end
        result # [0..19]
      end

      # @param [Array] terms contains Strings
      # @return [ActiveRecord::Relation, nil]
      #   cached matches full query string wildcarded
      def cached(terms)
        if terms.empty?
          nil
        else
          terms = terms.map { |s| [s + '%', '%' + s + '%'] }
          people_table[:cached].matches_any(terms.flatten)
        end
      end

      # @return [ActiveRecord::Relation]
      def first_last_cached
        terms = [options[:last_name], options[:first_name]].compact
        a     = cached(terms)
        return nil if a.nil?
        base_query.where(a.to_sql)
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
        # if a = and_clauses
        #   ::Person.where(and_clauses)
        # else
        #   ::Person.none
        # end
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
    def self.person_params(params, klass)
      t = klass.arel_table
      raise 'This isn\'t finished, or even known to be required.'
    end
  end
end
