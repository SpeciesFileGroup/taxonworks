class Tag < ActiveRecord::Base
  include Housekeeping
  
  acts_as_list scope: [:keyword_id]

  belongs_to :keyword
  belongs_to :tag_object, polymorphic: true

  validates :tag_object, presence: true
  validates :keyword, presence: true
  validates_uniqueness_of :keyword_id, scope: [ :tag_object_id, :tag_object_type]

end
