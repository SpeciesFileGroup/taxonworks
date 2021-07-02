module Queries
  module BiologicalAssociation

    # !! does not inherit from base query
    class Filter 

      # only collection objects

      # ----
      #
      # subject property
      # object property
      # any property
      #
      # nomenclature
      # descendants of subject
      # descendants of object
      # descendants of any
      #
      # ----

      # Params specific to AlternateValue
      attr_accessor :subject_global_id, :object_global_id, :biological_relationship_id, :any_global_id

      def initialize(params)
        @subject_global_id = params[:subject_global_id]
        @object_global_id = params[:object_global_id]
        @biological_relationship_id = params[:biological_relationship_id]
        @any_global_id = params[:any_global_id]
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          matching_subject_global_id, 
          matching_object_global_id,
          matching_any_global_id,
          matching_biological_relationship_id,
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
      def object_for(global_id)
        if o = GlobalID::Locator.locate(global_id) 
          o
        else
          nil
        end
      end

      def subject_matches(object)
        table["biological_association_subject_id"].eq(object.id).and(
          table["biological_association_subject_type"].eq(object.metamorphosize.class.name) 
        )
      end

      def object_matches(object)
        table["biological_association_object_id"].eq(object.id).and(
          table["biological_association_object_type"].eq(object.metamorphosize.class.name) 
        )
      end

      def matching_subject_global_id
        t = object_for(subject_global_id)
        return nil if t.nil? 
        subject_matches(t)
      end

      def matching_object_global_id
        t = object_for(object_global_id)
        return nil if t.nil? 
        object_matches(t)
      end

      def matching_any_global_id
        t = object_for(any_global_id)
        return nil if t.nil? 
        subject_matches(t).or(object_matches(t))
      end

      # @return [Arel::Node, nil]
      def matching_biological_relationship_id
        biological_relationship_id.blank? ? nil : table[:biological_relationship_id].eq(biological_relationship_id) 
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::BiologicalAssociation.where(and_clauses)
        else
          ::BiologicalAssociation.all
        end
      end

      # @return [Arel::Table]
      def table
        ::BiologicalAssociation.arel_table
      end
    end
  end
end
