module Queries
  module Document
    class Filter < Query::Filter

      PARAMS = [
        :document_id,
        :file_extension_group_name,
        document_id: [],
      ].freeze

      attr_accessor :document_id

      attr_accessor :file_extension_group_name

      def initialize(query_params)
        super

        @document_id = params[:document_id]
        @file_extension_group_name = params[:file_extension_group_name]
      end

      def document_id
        [@document_id].flatten.compact
      end

      def file_extension_facet
        return nil if !file_extension_group_name&.present?

        d = FILE_EXTENSIONS_DATA.find { |g|
          g[:group] == file_extension_group_name
        }

        d ||= {
          group: '',
          extensions: [
            {
              extension: '',
              content_type: '' # matches no document
            }
          ]
        }

        a = []
        d[:extensions].each { |e|
          a <<
            table[:document_file_content_type].eq(e[:content_type])
            .and(table[:document_file_file_name].matches('%' + e[:extension]))
        }

        q = a.shift
        a.each do |b|
          q = q.or(b)
        end

        q
      end

      def and_clauses
        [file_extension_facet]
      end
    end
  end
end