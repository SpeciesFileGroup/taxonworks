module Queries
  module Tag

    class Filter < Query::Filter

      PARAMS = [
        :keyword_id,
        :tag_object_type,
        :tag_object_id,
        keyword_id: [],
        tag_object_type: [],
        tag_object_id: [],
      ]

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
        super
      end

      def tag_object_type
        [@tag_object_type, global_object_type].flatten.compact
      end

      def tag_object_id
        [@tag_object_id, global_object_id].flatten.compact
      end

      # @return [Arel::Node, nil]
      def keyword_id_facet
        !keyword_id.empty? ? table[:keyword_id].eq_any(keyword_id)  : nil
      end

      # @return [Arel::Node, nil]
      def object_id_facet
        tag_object_id.empty? ? nil : table[:tag_object_id].eq_any(tag_object_id)
      end

      # @return [Arel::Node, nil]
      def tag_object_type_facet
        tag_object_type.empty? ? nil : table[:tag_object_type].eq_any(tag_object_type)
      end

      def and_clauses
        [ 
          #  ::Queries::Annotator.annotator_params(options, ::Tag),
          keyword_id_facet,
          matching_polymorphic_ids, # concern
          object_id_facet,
          tag_object_type_facet,
        ]
     end


    end
  end
end
