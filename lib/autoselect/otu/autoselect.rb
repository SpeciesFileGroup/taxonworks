# lib/autoselect/otu/autoselect.rb
module Autoselect
  module Otu
    class Autoselect < ::Autoselect::Base
      include ::Autoselect::Otu::Operators

      def resource_path
        '/otus/autoselect'
      end

      # Ordered level stack — defines the fuse escalation sequence.
      # OTU has no fast level; starts at smart, then escalates to CatalogOfLife.
      def levels
        [
          ::Autoselect::Otu::Levels::Smart.new,
          ::Autoselect::Otu::Levels::CatalogOfLife.new,
        ]
      end

      # @param record [Otu or OpenStruct]
      # @return [Hash] key-value pairs injected into the parent form on selection
      def response_values(record)
        { otu_id: record.id }
      end

      def record_label(record)
        record.name || record.try(:taxon_name)&.cached || "(OTU ##{record.id})"
      end

      def record_label_html(record)
        record_label(record)
      end

      def record_info(record)
        record.try(:taxon_name)&.cached if record.respond_to?(:name) && record.name.blank?
      end

      private

      # Override to handle new-OTU sentinel (extension with :_otu_new_form)
      # and CoL results (extension with :_col_extension).
      def format_results(records)
        records.map do |record|
          ext = {}
          ext = record._otu_new_form if record.respond_to?(:_otu_new_form) && record._otu_new_form
          ext = record._col_extension if record.respond_to?(:_col_extension) && record._col_extension

          {
            id: record.id,
            label: record_label(record),
            label_html: record_label_html(record),
            info: record_info(record),
            response_values: response_values(record),
            extension: ext
          }
        end
      end

    end
  end
end
