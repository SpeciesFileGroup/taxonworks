module Queries
  module DataAttribute

    # !! does not inherit from base query
    class Filter

      # General annotator options handling
      # happens directly on the params as passed
      # through to the controller, keep them
      # together here
      attr_accessor :options

      # Params specific to DataAttribute
      attr_accessor :value

      # @return [Array]
      attr_accessor :controlled_vocabulary_term_id

      attr_accessor :import_predicate

      attr_accessor :type

      attr_accessor :object_global_id

      attr_accessor :attribute_subject_type

      attr_accessor :attribute_subject_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @value = params[:value]
        @controlled_vocabulary_term_id = params[:controlled_vocabulary_term_id]
        @import_predicate = params[:import_predicate]
        @type = params[:type]

        @attribute_subject_id = params[:attribute_subject_id]
        @attribute_subject_type = params[:attribute_subject_type]
        @object_global_id = params[:object_global_id]
        @options = params
      end

      def controlled_vocabulary_term_id
        [@controlled_vocabulary_term_id].flatten.compact
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          ::Queries::Annotator.annotator_params(options, ::DataAttribute),
          matching_type,
          matching_value,
          matching_import_predicate,
          matching_attribute_subject_id,
          matching_attribute_subject_type,
          matching_controlled_vocabulary_term_id,
          matching_subject
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_subject
        if o = object_for
          table['attribute_subject_id'].eq(o.id).and(
            table['attribute_subject_type'].eq(o.metamorphosize.class.name)
          )
        else
          nil
        end
      end

      # @return [Arel::Node, nil]
      def matching_attribute_subject_type
        !attribute_subject_type.blank? ? table[:attribute_subject_type].eq(attribute_subject_type)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_attribute_subject_id
        !attribute_subject_id.blank? ? table[:attribute_subject_id].eq(attribute_subject_id)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_value
        value.blank? ? nil : table[:value].eq(value)
      end

      # @return [Arel::Node, nil]
      def matching_import_predicate
        import_predicate.blank? ? nil : table[:import_predicate].eq(import_predicate)
      end

      # @return [Arel::Node, nil]
      def matching_type
        type.blank? ? nil : table[:type].eq(type)
      end

      # @return [Arel::Node, nil]
      def matching_controlled_vocabulary_term_id
        controlled_vocabulary_term_id.empty? ? nil : table[:controlled_vocabulary_term_id].eq_any(controlled_vocabulary_term_id)
      end

      # @return [ActiveRecord object, nil]
      # TODO: DRY
      def object_for
        if o = GlobalID::Locator.locate(object_global_id)
          o
        else
          nil
        end
      end

      # @return [ActiveRecord::Relation]
      def all
        if _a = and_clauses
          ::DataAttribute.where(and_clauses)
        else
          ::DataAttribute.all
        end
      end

      # @return [Arel::Table]
      def table
        ::DataAttribute.arel_table
      end

    end
  end
end
