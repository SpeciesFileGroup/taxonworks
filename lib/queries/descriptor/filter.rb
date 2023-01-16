module Queries
  module Descriptor
    class Filter < Query::Filter

      include Queries::Concerns::Tags
      include Queries::Concerns::Notes

      # @params params ActionController::Parameters
      # @return ActionController::Parameters
      def self.base_params(params)
        params.permit(
          :term,
          :term_target,
          :term_exact,
          :descriptor_type,
          :observation_matrix_id,
          :observation_matrices,
          :observations,
        )
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

      # @param observation_matrices [String, Boolean]
      # @return [Boolean] 
      attr_accessor :observation_matrices

      # @param observations [String, Boolean]
      # @return [Boolean] 
      attr_accessor :observations

      # @param [Hash] params
      def initialize(params)
        @term = params[:term]
        @term_target = params[:term_target]
        @term_exact = boolean_param(params, :term_exact)
        @observation_matrix_id = params[:observation_matrix_id]
        @descriptor_type = params[:descriptor_type]
        @observation_matrices = boolean_param(params, :observation_matrices)
        @observations = boolean_param(params, :observations)

        set_notes_params(params)
        set_tags_params(params)
        set_user_dates(params)

        super
      end

      def observation_matrix_id
        [@observation_matrix_id].flatten.compact.uniq
      end

      def descriptor_type 
        [@descriptor_type].flatten.compact.uniq
      end

      def term_facet
        return nil if term.blank?
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

      def observation_matrices_facet
        return nil if observation_matrices.nil?
        if observation_matrices
          ::Descriptor.joins(:observation_matrices) 
        else
          ::Descriptor.where.missing(:observation_matrices) 
        end
      end

      def observations_facet
        return nil if observation_matrices.nil?
        if observation_matrices
          ::Descriptor.joins(:observations) 
        else
          ::Descriptor.where.missing(:observations) 
        end
      end

      def base_and_clauses
        [ term_facet,
          descriptor_type_facet,
        ].compact
      end

      def base_merge_clauses
        [ observations_facet,
          observation_matrices_facet,
          observation_matrix_id_facet,
          source_query_facet,
        ].compact
      end

    end
  end
end

