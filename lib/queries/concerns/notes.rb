# Helpers and facets for queries that reference Notes.
#
# Test coverage is currently in spec/lib/queries/collection_object/filter_spec.rb.
#
module Queries::Concerns::Notes

  extend ActiveSupport::Concern

  def self.params
    [
      :note_exact,
      :note_text,
      :notes
    ]
  end

  included do
    # @return [String, nil]
    #   text to match
    attr_accessor :note_text

    # @return [Boolean, nil]
    attr_accessor :note_exact

    # @return [Boolean, nil]
    # @params notes ['true', 'false', Boolean]
    #   Only return objects with notes
    attr_accessor :notes
  end

  def set_notes_params(params)
    @note_exact = params[:note_exact]
    @note_text = params[:note_text]
    @notes = boolean_param(params, :notes)
  end

  # @return [Arel::Table]
  def note_table
    ::Note.arel_table
  end

  def self.merge_clauses
    [
      :note_text_facet,
      :notes_facet
    ]
  end

  def note_text_facet
    return nil if note_text.blank?

    if note_exact
      referenced_klass.joins(:notes).where(note_table[:text].eq(note_text))
    else
      referenced_klass.joins(:notes).where(
        note_table[:text].matches('%' + note_text + '%')
      )
    end
  end

  def notes_facet
    return nil if notes.nil?
    if notes
      referenced_klass.joins(:notes).distinct
    else
      referenced_klass.where.missing(:notes)
    end
  end

end
