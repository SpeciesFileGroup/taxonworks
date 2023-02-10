module Queries
  module OriginRelationship
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::OriginRelationship)

      # attr_accessor :object_global_id  from Queries::Concerns::Polymorphic
      # attr_accessor :polymorphic_ids   from Queries::Concerns::Polymorphic

      PARAMS = [
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

        set_polymorphic_ids(params)
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

      def matching_new_object_facet
        return nil if new_object_global_id.nil?
        table[:new_object_type].eq(new_object.class.base_class)
          .and(table[:new_object_id].eq(new_object.id))
      end

      def matching_old_object_facet
        return nil if old_object_global_id.nil?
        table[:old_object_type].eq(old_object.class.base_class)
          .and(table[:old_object_id].eq(old_object.id))
      end

      def and_clauses
        [
          matching_new_object_facet,
          matching_old_object_facet,
          matching_polymorphic_ids
        ]
      end

    end
  end
end
