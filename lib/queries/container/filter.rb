module Queries
  module Container
    class Filter < Query::Filter
      include Queries::Concerns::Tags

      PARAMS = [
        :container_id,
        :type,
        :name,
        container_id: [],
      ].freeze

      attr_accessor :container_id

      attr_accessor :type

      attr_accessor :name

      # @param params [Hash]
      def initialize(query_params)
        super

        @container_id = params[:container_id]
        @type = params[:type]
        @name = params[:name]

        set_tags_params(params)
      end

      def container_id
        [@container_id].flatten.compact
      end


      def container_id_facet
        return nil if container_id.empty?
        table[:id].in(container_id)
      end

      def type_facet
        return nil if @type.blank?
        table[:type].equal(@type)
      end

      def name_facet
        return nil if @name.blank?
        table[:name].equal(@name)
      end

      # If we add merge_clauses then we likely have
      # to deal with excluding the `xml` field from distinct+intersection calls
      # via a custom base_query field.

      def and_clauses
        [
          container_id_facet,
          type_facet,
          name_facet
        ]
      end

    end
  end
end
