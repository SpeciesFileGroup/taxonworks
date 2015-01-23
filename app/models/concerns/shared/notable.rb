module Shared::Notable
  extend ActiveSupport::Concern

  included do
    # Validation happens on the parent side!
    has_many :notes, as: :note_object, validate: true

    # Todo: this likely doesn't do anything.
    accepts_nested_attributes_for :notes
  end 

   # module ClassMethods
   # end

  def concatenated_notes_string
    s = notes.order(updated_at: :desc).collect{|n| n.note_string}.join('|') 
    s == "" ? nil : s
  end

=begin deprecated - has_notes? is defined in is_data to mean that the class is notable.
  def has_notes?
    self.notes.any?
  end
=end

end
