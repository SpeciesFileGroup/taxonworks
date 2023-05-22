class CachedMap < ApplicationRecord
  include Housekeeping::Projects
  include Housekeeping::Timestamps
  include Shared::IsData

  belongs_to :otu

  has_many :cached_map_items

  validates_presence_of :otu
  validates_presence_of :geometry
  validates_presence_of :reference_count

  def synced?
    #  sum reference_count of cached_map_items && most recent item date is <= this update date
  end

end
