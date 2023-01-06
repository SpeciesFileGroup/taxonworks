# Helpers and facets for queries that reference Notes.
#
# Test coverage is currently in spec/lib/queries/collection_object/filter_spec.rb.
#
module Queries::Concerns::Notes

  extend ActiveSupport::Concern

  included do

    attr_accessor :note_text
    attr_accessor :note_exact

    # @return [Boolean, nil]
    # @params notes ['true', 'false', nil]
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

  def note_text_facet
    return nil if note_text.blank?
    k = table.name.classify.safe_constantize

    if note_exact
      k.joins(:notes).where(note_table[:text].eq(note_text))
    else
      k.joins(:notes).where(
        note_table[:text].matches('%' + note_text + '%')
      )
    end
  end

  def notes_facet
    return nil if notes.nil?
    k = table.name.classify.safe_constantize

    if notes
      k.joins(:notes).distinct
    else
      k.left_outer_joins(:notes)
        .where(notes: {id: nil})
    end
  end

end
