#
#
class CachedMapItemTranslation < ApplicationRecord
  include Housekeeping::Timestamps
  include Shared::IsData

  belongs_to :geographic_item
  belongs_to :translated_geographic_item, class_name: 'GeographicItem'

  validates_presence_of :geographic_item, :translated_geographic_item
  validates_uniqueness_of :geographic_item_id, scope: [:translated_geographic_item_id, :cached_map_type]

end
