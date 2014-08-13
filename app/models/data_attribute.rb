class DataAttribute < ActiveRecord::Base
  include Housekeeping::Users

  belongs_to :attribute_subject, polymorphic: true
  validates :attribute_subject, presence: true
  validates_presence_of :type, :value
  validates_uniqueness_of :value, scope: [:attribute_subject_id, :attribute_subject_type, :type]
end
