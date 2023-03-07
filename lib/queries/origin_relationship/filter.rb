module Queries
  module OriginRelationship
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::OriginRelationship)

      PARAMS = [
        *::OriginRelationship.related_foreign_keys.map(&:to_sym), # TODO:!?!
        :origin_relationship_id,
        :new_object_global_id,
        :old_object_global_id,
        origin_relationship_id: []
      ].freeze

      attr_accessor :origin_relationship_id
      attr_accessor :new_object_global_id
      attr_accessor :old_object_global_id

      def initialize(query_params)
        super

        @origin_relationship_id = params[:origin_relationship_id]
        @new_object_global_id = params[:new_object_global_id]
        @old_object_global_id = params[:old_object_global_id]

        set_polymorphic_params(params)
      end

      def origin_relationship_id
        [@origin_relationship_id].flatten.compact
      end

      def new_object
        if o = GlobalID::Locator.locate(new_object_global_id)
          o
        else
          nil
        end
      end

      def old_object
        if o = GlobalID::Locator.locate(old_object_global_id)
          o
        else
          nil
        end
      end

      def new_object_facet
        return nil if new_object_global_id.nil?
        table[:new_object_type].eq(new_object.class.base_class)
          .and(table[:new_object_id].eq(new_object.id))
      end

      def old_object_facet
        return nil if old_object_global_id.nil?
        table[:old_object_type].eq(old_object.class.base_class)
          .and(table[:old_object_id].eq(old_object.id))
      end


      def polymorphic_id_facet
        return nil if polymorphic_id.blank?
        table[referenced_klass.annotator_id].eq(polymorphic_id).and(table[referenced_klass.annotator_type].eq(polymorphic_type))
      end

      def and_clauses
        [
          new_object_facet,
          old_object_facet,
        ]
      end

    end
  end
end
