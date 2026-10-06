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
          ::Autoselect::TaxonName::Levels::CatalogueOfLife.new,
        ]
      end

      # @param record [::TaxonName or OpenStruct]
      # @return [Hash] key-value pairs injected into the parent form on selection
      def response_values(record)
        { taxon_name_id: record.id }
      end

      private

      # Override to populate extension from CoL pseudo-records.
      def format_results(records, level_instance)
        records.map do |record|
          {
            id: record.id,
            global_id: record.respond_to?(:to_global_id) ? record.to_global_id.to_s : nil,
            label: level_instance.record_label(record),
            label_html: level_instance.record_label_html(record, effective_term),
            info_html: @show_info ? level_instance.record_info_html(record) : '',
            response_values: response_values(record),
            extension: record.respond_to?(:_col_extension) ? record._col_extension : {}
          }
        end
      end

    end
  end
end
