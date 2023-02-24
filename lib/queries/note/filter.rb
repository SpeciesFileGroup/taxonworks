module Queries
  module Note
    class Filter < Query::Filter

      include Concerns::Polymorphic
      polymorphic_klass(::Identifier)

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
        table[:note_object_type].eq_any(note_object_type)
      end

      def note_object_id_facet
        return nil if note_object_id.empty?
        table[:note_object_id].eq_any(note_object_id)
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
