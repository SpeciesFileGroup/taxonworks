module Queries
  module Confidence 

    # !! does not inherit from base query
    class Filter 
      include Concerns::Polymorphic
      polymorphic_klass(::Confidence)

      # Params specific to Confidence 

      # Array, Integer
      attr_accessor :confidence_level_id, :object_global_id, :confidence_object_type

      # @params params [ActionController::Parameters]
      def initialize(params)
        @confidence_level_id = [params[:confidence_level_id]].flatten.compact
        @object_global_id = params[:object_global_id]
        @confidence_object_type = params[:confidence_object_type]
        set_polymorphic_ids(params)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_confidence_level_id,
          matching_confidence_object_type,
          matching_object,
          matching_polymorphic_ids
        ].compact

        return nil if clauses.empty? 
        
        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
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

      # TODO: Dry
      # @return [Arel::Node, nil]
      def matching_object
        if o = object_for
          table["confidence_object_id"].eq(o.id).and(
              table["confidence_object_type"].eq(o.metamorphosize.class.name)
          )
        else
          nil
        end
      end

      # @return [Arel::Node, nil]
      def matching_confidence_level_id
        !confidence_level_id.blank? ? table[:confidence_level_id].eq_any(confidence_level_id)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_confidence_object_type
        !confidence_object_type.blank? ? table[:confidence_object_type].eq(confidence_object_type)  : nil
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Confidence.where(and_clauses)
        else
          ::Confidence.all
        end
      end

      # @return [Arel::Table]
      def table
        ::Confidence.arel_table
      end
    end
  end
end
