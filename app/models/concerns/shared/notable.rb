module Shared::Notable
  extend ActiveSupport::Concern

  included do
    has_many :notes, as: :note_object
  end 

  module ClassMethods
  end

  def has_notations?
    self.notes.count > 0
  end
end
