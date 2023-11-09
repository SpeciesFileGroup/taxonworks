
# Tracks whether/when an object that is a source for CachedMap has been processed.
class CachedMapRegister < ApplicationRecord
  include Housekeeping::Projects
  include Housekeeping::Timestamps

  include Shared::IsData

  belongs_to :cached_map_register_object, polymorphic: true

  validates_presence_of :cached_map_register_object

  # Should not do this for speed reasons, just fix algorithim
  # validates_uniqueness_of :cached_map_register_object

end
