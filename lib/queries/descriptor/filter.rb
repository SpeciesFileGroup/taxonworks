module Queries
  module Descriptor
    class Filter < Query::Filter

     # @params params ActionController::Parameters
      # @return ActionController::Parameters
      def self.base_params(params)
        params.permit(
          :term,
          :term_target,
          :term_exact,
          :observation_matrix_id,
        )
      end

      # @params params ActionController::Parameters
      def self.permit(params)
        deep_permit(:desriptor, params)
      end

      include Queries::Helpers

      # @param name [String, Symbol]
      #   matches against name, short_name, description, description_name, key_name
      #   See `term_target`, `term_exact`
      attr_accessor :term

      # @param term_exact [String, Boolean]
      # @return [Boolean] 
      attr_accessor :term_exact

      # @return [String, Symbol ni]
      # @return Symbol, nil
      attr_accessor :term_target

      # @param observation_matrix_id [Array, String, Numeric]
      # @return [Array]
      attr_accessor :observation_matrix_id

      # @return [Array, nil]
      # @param descriptor_type [String]
      #   a full type like Descriptor::Continuous
      attr_accessor :descriptor_type

      # @param [Hash] params
      def initialize(params)
        @term = params[:name]
        @term_target = params[:name]

        @term_exact = boolean_param(params, :term_exact)

        @observation_matrix_id = params[:observation_matrix_id]

        @descriptor_type = params[:descriptor_type]

        # set_tags_params(params)
        super
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact.uniq
      end

      def descriptor_type 
        [@descriptor_type].flatten.compact.uniq
      end

      def term_facet
        return nil if term.empty?
        w =  '%' + term.gsub(/\s+/, '%') + '%' 

        if term_exact
          if term_target.nil?
            table[:name].eq(term)
              .or(table[:short_name].eq(term))
              .or(table[:description].eq(term))
              .or(table[:description_name].eq(term))
              .or(table[:key_name].eq(term))
          else
            table[term_target].eq(term)
          end
        else
          if term_target.nil?
            table[:name].matches(w)
              .or(table[:short_name].matches(w))
              .or(table[:description].matches(w))
              .or(table[:description_name].matches(w))
              .or(table[:key_name].matches(w))
          else
            table[term_target].matches(tw)
          end
        end
      end

      def observation_matrix_id_facet
        return nil if observation_matrix_id.blank?
        ::Descriptor.joins(:observation_matrices)
          .where(observation_matrices: {id: :observation_matrix_id})
      end
     
      def descriptor_type_facet
        return nil if descriptor_type.blank?
        table[:type].eq_any(descriptor_type)
      end

      # @return [ActiveRecord::Relation, nil]
      def and_clauses
        clauses = [
          term_facet,
          descriptor_type_facet,
        ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      def base_merge_clauses
        clauses = []

        clauses += [
          observatoin_matrix_id_facet,
          source_query_facet,
        ].compact
      end

      def merge_clauses
        clauses = base_merge_clauses
        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.merge(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        a = and_clauses
        b = merge_clauses

        if a && b
          b.where(a).distinct
        elsif a
          ::Descriptor.where(a).distinct
        elsif b
          b.distinct
        else
          ::Descriptor.all
        end
      end

      end
    end
  end

