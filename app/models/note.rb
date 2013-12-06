class Note < ActiveRecord::Base
  include Housekeeping
  belongs_to :note_object, polymorphic: true
  validates :note_object, presence: true
  validates_presence_of :text
end
