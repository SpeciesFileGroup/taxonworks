# Shared code for extending data classes with Notes.
#
module Shared::Notes
  extend ActiveSupport::Concern

  included do
    Note.related_foreign_keys.push self.name.foreign_key

    # Validation happens on the parent side!
    has_many :notes, as: :note_object, validate: true, dependent: :destroy, inverse_of: :note_object

    accepts_nested_attributes_for :notes, reject_if: :reject_notes, allow_destroy: true
  end

  def concatenated_notes_string
    s = notes.order(updated_at: :desc).collect { |n| n.note_string }.join('||')
    s == '' ? nil : s
  end

  protected

  def reject_notes(attributed)
    attributed['text'].blank?
  end

end
