module Queries
  module Note 

    class Filter 

      # @param text [String, nil]
      #   wildcard wrapped, always, to match against `text`
      attr_accessor :text

      # @return [Array]
      # @params note_object_type array or string
      attr_accessor :note_object_type

      # @return [Array]
      # @params note_object_id array or string (integer)
      attr_accessor :note_object_id

      attr_accessor :object_global_id

      attr_accessor :project_id

      def initialize(params)
        @text = params[:text]
        @note_object_type = params[:note_object_type]
        @note_object_id = params[:note_object_id]
        @object_global_id = params[:object_global_id]
        @project_id = params[:project_id]
      end

      def note_object_id
        [@note_object_id].flatten.compact
      end

      def note_object_type
        [@note_object_type].flatten.compact
      end

      def table
        ::Note.arel_table
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

      def object_global_id_facet
        return nil if object_global_id.nil?
        o = GlobalID::Locator.locate(object_global_id)
        k = o.class.base_class.name
        id = o.id 
        table[:note_object_id].eq(o.id).and(table[:note_object_type].eq(k)) 
      end

      # @return [ActiveRecord::Relation]
      def and_clauses
        clauses = [
          text_facet,
          note_object_id_facet,
          note_object_type_facet,
          object_global_id_facet,
        ].compact

        a = clauses.shift
        clauses.each do |b|
          a = a.and(b)
        end
        a
      end

      # @return [ActiveRecord::Relation]
      def all 
        q = nil
        if a = and_clauses
          q = ::Note.where(and_clauses)
        else
          q = ::Note.all
        end

        q = q.where(project_id: project_id) if !project_id.blank?
        q
      end
    end
  end
end
