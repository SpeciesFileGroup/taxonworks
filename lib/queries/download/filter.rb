module Queries
  module Download
    class Filter < Query::Filter

      PARAMS = [
        :download_id,
        :download_type,
        :request,
        download_id: [],
        download_type: [],
      ].freeze

      # TODO: Add date/expiry facets

      attr_accessor :download_id

      # @param download_type [Array. String]
      #   like 'Download::DwcArchive', one of the models in app/models/download
      attr_accessor :download_type

      # @param request [String]
      #   matches Download#request; used e.g. to scope per-OTU CoLDP downloads
      attr_accessor :request

      # @params params [ActionController::Parameters]
      def initialize(query_params)
        super
        @download_type = params[:download_type]
        @download_id = params[:download_id]
        @request = params[:request]
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

      def request_facet
        return nil if request.blank?
        table[:request].eq(request)
      end

      def and_clauses
        [
          download_type_facet,
          request_facet
        ]
      end

    end
  end
end
