module Queries
  module Note
    class Filter < Query::Filter

      include Concerns::Polymorphic
      include Queries::Concerns::Sortable
      polymorphic_klass(::Note)

      def self.sortable_columns
        {
          'id'               => sort_by_direct_column('notes.id'),
          'note_object_type' => sort_by_direct_column('notes.note_object_type'),
          'text'             => sort_by_direct_column('notes.text'),
          'created_at'       => sort_by_direct_column('notes.created_at'),
          'updated_at'       => sort_by_direct_column('notes.updated_at'),
          'created_by'       => sort_by_direct_column('notes.created_by_id')
        }
      end

      PARAMS = [
        *::Note.related_foreign_keys.map(&:to_sym),
        :note_id,
        :text,
        :note_object_type,
        :note_object_id,
        note_id: [],
        note_object_id: [],
        note_object_type: [],
      ].freeze

      # @return Array
      attr_accessor :note_id

      # @param text [String, nil]
      #   wildcard wrapped, always, to match against `text`
      attr_accessor :text

      # @return [Array]
      # @params note_object_type array or string
      attr_accessor :note_object_type

      # @return [Array]
      # @params note_object_id array or string (integer)
      attr_accessor :note_object_id

      def initialize(query_params)
        super

        @note_id = params[:note_id]
        @text = params[:text]
        @note_object_type = params[:note_object_type]
        @note_object_id = params[:note_object_id]

        set_polymorphic_params(params)
      end

      def note_id
        [@note_id].flatten.compact
      end

      def note_object_id
        [@note_object_id].flatten.compact
      end

      def note_object_type
        [@note_object_type].flatten.compact
      end

      def text_facet
        return nil if text.blank?
        table[:text].matches('%' + text + '%')
      end

      def note_object_type_facet
        return nil if note_object_type.empty?
        table[:note_object_type].in(note_object_type)
      end

      def note_object_id_facet
        return nil if note_object_id.empty?
        table[:note_object_id].in(note_object_id)
      end

      def and_clauses
        [
          text_facet,
          note_object_id_facet,
          note_object_type_facet,
        ]
      end
    end
  end
end
