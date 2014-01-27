class Tag < ActiveRecord::Base
  include Housekeeping

  belongs_to :keyword
  belongs_to :tag_object, polymorphic: true
  validates :tag_object, presence: true
  validates :keyword, presence: true
  validates_uniqueness_of :keyword_id, scope: [:tag_object]

end
