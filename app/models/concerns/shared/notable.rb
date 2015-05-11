module Shared::Notable
  extend ActiveSupport::Concern

  included do
    # Validation happens on the parent side!
    has_many :notes, as: :note_object, validate: true, dependent: :destroy

    accepts_nested_attributes_for :notes
  end 
  
  def concatenated_notes_string
    s = notes.order(updated_at: :desc).collect{|n| n.note_string}.join('|') 
    s == "" ? nil : s
  end

end
