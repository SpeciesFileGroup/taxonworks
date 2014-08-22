module Shared::Notable
  extend ActiveSupport::Concern

  included do
    has_many :notes, as: :note_object, validate: false
    accepts_nested_attributes_for :notes
  end 

  module ClassMethods
  end

  # TODO: Move to Draper if we use it 
  def concatenated_notes_string
    s = notes.order(updated_at: :desc).collect{|n| n.note_string}.join('|') 
    s == "" ? nil : s
  end

  def has_notations?
    self.notes.count > 0
  end
end
