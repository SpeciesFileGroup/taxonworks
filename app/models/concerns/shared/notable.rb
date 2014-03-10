module Shared::Notable
  extend ActiveSupport::Concern

  included do
    has_many :notes, as: :note_object, validate: false
    accepts_nested_attributes_for :notes
  end 

  module ClassMethods
  end

  def has_notations?
    self.notes.count > 0
  end
end
