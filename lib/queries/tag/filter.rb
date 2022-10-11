module Queries
  module Tag

    # !! does not inherit from base query
    class Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Tag)

      # Array, Integer
      attr_accessor :keyword_id

      # Array, Integer
      attr_accessor :tag_object_type

      # Array, Integer
      attr_accessor :tag_object_id

      # From concern
      # attr_accessor :object_global_id

      # @params params [ActionController::Parameters]
      def initialize(params)
        @keyword_id = [params[:keyword_id]].flatten.compact
        @tag_object_type = params[:tag_object_type]
        @tag_object_id = params[:tag_object_id]
        @object_global_id = params[:object_global_id]

        set_polymorphic_ids(params)
      end

      def tag_object_type
        [@tag_object_type, global_object_type].flatten.compact
      end

      def tag_object_id
        [@tag_object_id, global_object_id].flatten.compact
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          #  ::Queries::Annotator.annotator_params(options, ::Tag),
          matching_keyword_id,
          matching_polymorphic_ids,
          matching_tag_object_id,
          matching_tag_object_type,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [Arel::Node, nil]
      def matching_keyword_id
        !keyword_id.empty? ? table[:keyword_id].eq_any(keyword_id)  : nil
      end

      # @return [Arel::Node, nil]
      def matching_tag_object_id
        tag_object_id.empty? ? nil : table[:tag_object_id].eq_any(tag_object_id)
      end

      # @return [Arel::Node, nil]
      def matching_tag_object_type
        tag_object_type.empty? ? nil : table[:tag_object_type].eq_any(tag_object_type)
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Tag.where(and_clauses).distinct
        else
          ::Tag.all
        end
      end

      # @return [Arel::Table]
      def table
        ::Tag.arel_table
      end
    end
  end
end
