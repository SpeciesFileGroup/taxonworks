module Queries
  module CollectingEvent 

    # !! does not inherit from base query
    class Filter 

      include Queries::Concerns::DateRanges

      ATTRIBUTES = (::CollectingEvent.column_names - %w{project_id created_by_id updated_by_id created_at updated_at})

      ATTRIBUTES.each do |a|
        class_eval { attr_accessor a.to_sym }
      end

      def initialize(params)
        set_attributes(params)
        set_dates(params)
      end

      def set_attributes(params)
        ATTRIBUTES.each do |a|
          send("#{a}=", params[a.to_sym]) 
        end
      end

      # @return [Arel::Table]
      def table
        ::CollectingEvent.arel_table
      end

      def attribute_clauses
        c = []
        ATTRIBUTES.each do |a|
          if v = send(a)
            c.push table[a.to_sym].eq(v)
          end
        end
        c
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = attribute_clauses
        #
        # = [
        #   matching_subject_global_id, 
        #   matching_object_global_id,
        #   matching_any_global_id,
        #   matching_biological_relationship_id,
        # ].compact

        return nil if clauses.empty?

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::CollectingEvent.where(and_clauses)
        else
          ::CollectingEvent.all
        end
      end

  
      protected

    end
  end
end
