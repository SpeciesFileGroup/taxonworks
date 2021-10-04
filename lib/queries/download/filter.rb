module Queries
  module Download 
    class Filter < Queries::Query 

      # TODO: Add date/expiry facets

      # @param download_type [Array. String]
      #   like 'Download::DwcArchive', one of the models in app/models/download
      attr_accessor :download_type

      # @params params [ActionController::Parameters]
      def initialize(params)
        @download_type = params[:download_type]
      end

      def table
        ::Download.arel_table
      end

      def download_type
        [@download_type].flatten.compact
      end

      def download_type_facet
        return nil if download_type.nil?
        table[:type].eq_any(download_type)
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all
        if a = and_clauses
          ::Download.where(and_clauses)
        else
          ::Download.all
        end
      end

      # @return [Arel::Table]
      def table
        ::Download.arel_table
      end
    end
  end
end
