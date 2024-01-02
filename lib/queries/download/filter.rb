module Queries
  module Download
    class Filter < Query::Filter

      PARAMS = [
        :download_id,
        :download_type,
        download_id: [],
        download_type: [],
      ].freeze

      # TODO: Add date/expiry facets

      attr_accessor :download_id

      # @param download_type [Array. String]
      #   like 'Download::DwcArchive', one of the models in app/models/download
      attr_accessor :download_type

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @download_type = params[:download_type]
        @download_Id = params[:download_id]
      end

      def download_id
        [@download_id].flatten.compact
      end

      def download_type
        [@download_type].flatten.compact
      end

      def download_type_facet
        return nil if download_type.nil?
        table[:type].in(download_type)
      end

      def and_clauses
        [
          download_type_facet
        ]
      end

    end
  end
end
