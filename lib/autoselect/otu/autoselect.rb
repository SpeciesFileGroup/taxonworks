# lib/autoselect/otu/autoselect.rb
module Autoselect
  module Otu
    class Autoselect < ::Autoselect::Base
      include ::Autoselect::Otu::Operators

      def resource_path
        '/otus/autoselect'
      end

      # Ordered level stack — defines the fuse escalation sequence.
      #
      # Levels::ColValidName is conditional: it's a task-specific tool (currently
      # print_label2), not a default OTU search strategy, so it's only included when
      # the caller explicitly asks for it via the col_valid_names param — never appears
      # in the level map/preferences modal for any other OTU autoselect field.
      def levels
        stack = [
          ::Autoselect::Otu::Levels::Fast.new,
          ::Autoselect::Otu::Levels::Smart.new,
        ]
        stack << ::Autoselect::Otu::Levels::ColValidName.new if col_valid_names?
        stack << ::Autoselect::Otu::Levels::CatalogueOfLife.new
        stack
      end

      # @param record [Otu or OpenStruct]
      # @return [Hash] key-value pairs injected into the parent form on selection
      def response_values(record)
        { otu_id: record.id }
      end

      private

      # Override to handle new-OTU sentinel (extension with :_otu_new_form)
      # and CoL results (extension with :_col_extension).
      def format_results(records, level_instance)
        records.map do |record|
          ext = {}
          ext = record._otu_new_form if record.respond_to?(:_otu_new_form) && record._otu_new_form
          ext = record._col_extension if record.respond_to?(:_col_extension) && record._col_extension

          {
            id: record.id,
            global_id: record.respond_to?(:to_global_id) ? record.to_global_id.to_s : nil,
            label: level_instance.record_label(record),
            label_html: level_instance.record_label_html(record, effective_term),
            info_html: @show_info ? level_instance.record_info_html(record) : '',
            response_values: response_values(record),
            extension: ext
          }
        end
      end

      # @return [Boolean] whether the caller asked for Levels::ColValidName to be
      #   included in the level stack — passed through from the controller as a
      #   level param, e.g. `?col_valid_names=true`.
      def col_valid_names?
        level_params[:col_valid_names].to_s == 'true'
      end

    end
  end
end
