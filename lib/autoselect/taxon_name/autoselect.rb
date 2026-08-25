# lib/autoselect/taxon_name/autoselect.rb
module Autoselect
  module TaxonName
    class Autoselect < ::Autoselect::Base

      def resource_path
        '/taxon_names/autoselect'
      end

      # Ordered level stack — defines the fuse escalation sequence.
      #
      # Levels::ColValidName is always the 4th level: fast/smart/catalogue_of_life
      # get a shot at the raw term first, and only once those all come up empty does
      # the fuse escalate to resolving CoL synonymy. It's `is_default` false (see
      # Autoselect::Level#is_default), so it stays present-but-unchecked in the
      # preferences modal until a user opts in.
      def levels
        [
          ::Autoselect::TaxonName::Levels::Fast.new,
          ::Autoselect::TaxonName::Levels::Smart.new,
          ::Autoselect::TaxonName::Levels::CatalogueOfLife.new,
          ::Autoselect::TaxonName::Levels::ColValidName.new,
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
