module Shared::Notable
  extend ActiveSupport::Concern

  included do
    has_many :notes
  end 

  module ClassMethods
    def notes(notable_obj_id)
      # return an array of notes attached to the notable obj
      Note.where(:note_object_id => notable_obj_id)
    end
  end

  def has_notations?(notable_obj_id)
    return true if notes(notable_obj_id).count > 0
    return false
  end
end
