module Queries
  module Documentation

    class Filter < Query::Filter
      include Concerns::Polymorphic
      polymorphic_klass(::Attribution)

      PARAMS = [
        *::Documentation.related_foreign_keys.map(&:to_sym), 
        :documentation_id,
        documentation_id: []
      ].freeze

      attr_accessor :documentation_id

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @documentation_id = params[:documentation_id]
        set_polymorphic_params(params)
      end

      def documentation_id
        [@documentation_id].flatten.compact
      end

    end
  end
end
