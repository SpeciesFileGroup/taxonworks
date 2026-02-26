# lib/autoselect/taxon_name/autoselect.rb
module Autoselect
  module TaxonName
    class Autoselect < ::Autoselect::Base

      def resource_path
        '/taxon_names/autoselect'
      end

      # Ordered level stack — defines the fuse escalation sequence.
      def levels
        [
          ::Autoselect::TaxonName::Levels::Fast.new,
          ::Autoselect::TaxonName::Levels::Smart.new,
          ::Autoselect::TaxonName::Levels::CatalogOfLife.new,
        ]
      end

      # @param record [::TaxonName or OpenStruct]
      # @return [Hash] key-value pairs injected into the parent form on selection
      def response_values(record)
        { taxon_name_id: record.id }
      end

      def record_label(record)
        record.cached || record.name
      end

      def record_label_html(record)
        record_label(record)
      end

      def record_info(record)
        parts = []
        if record.respond_to?(:rank_string) && record.rank_string.present?
          parts << record.rank_string.split('::').last.downcase
        end
        if record.respond_to?(:cached_valid_taxon_name_id) && record.id.present?
          parts << (record.id == record.cached_valid_taxon_name_id ? 'valid' : 'synonym')
        end
        parts.join(', ').presence
      end

      private

      # Override to populate extension from CoL pseudo-records.
      def format_results(records)
        records.map do |record|
          {
            id: record.id,
            label: record_label(record),
            label_html: record_label_html(record),
            info: record_info(record),
            response_values: response_values(record),
            extension: record.respond_to?(:_col_extension) ? record._col_extension : {}
          }
        end
      end

    end
  end
end
