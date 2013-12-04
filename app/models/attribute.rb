class Attribute < ActiveRecord::Base

  include Housekeeping

  belongs_to :attribute_subject, polymorphic: true
  validates :attribute_subject, presence: true
  validates_presence_of :type, :value
end
