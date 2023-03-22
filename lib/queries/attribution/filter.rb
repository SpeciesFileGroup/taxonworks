module Queries
  module Attribution

    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Attribution)

      PARAMS = [
        *::Attribution.related_foreign_keys.map(&:to_sym),
        :attriution_id,
        attribution_id: []
      ].freeze

      attr_accessor :attribution_id

      def initialize(query_params)
        super
        @attribution_id = params[:attribution_id]
        set_polymorphic_params(params)
      end

      def attribution_id
        [@attribution_id].flatten.compact
      end

    end
  end
end
