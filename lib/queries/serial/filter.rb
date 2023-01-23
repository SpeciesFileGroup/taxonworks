module Queries
  module Serial

    class Filter << Query::Filter

      include Queries::Concerns::DataAttributes

      PARAMS = [
        :name
      ]

      # @param [String]
      #   matching name exactlyjk 
      attr_accessor :name

      def initialize(params)
        @name = params[:name]
        set_data_attribute_params(params)
        super
      end

      def project_id_facet
        nil
      end

      def name_facet
        return nil if nil.blank?
        table[:name].eq(name)
      end
      
      def and_clauses
        [ name_facet ]
     end

    end
  end
end
