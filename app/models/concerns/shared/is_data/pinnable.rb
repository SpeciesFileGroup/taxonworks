# Shared code pinning objects (adding them to your pinboard). 
#
module Shared::IsData::Pinnable
  extend ActiveSupport::Concern

  included do
    has_many :pinboard_items, as: :pinned_object, dependent: :destroy
  
    scope :pinned_by, -> (user_id) { joins(:pinboard_items).where(pinboard_items: {user_id: user_id}) } 
    scope :pinboard_inserted, -> { joins(:pinboard_items).where(pinboard_items: {is_inserted: true}) } 
  end

  # @return [Boolean]
  #   whether the object is pinned by the user
  def pinned?(user)
    user.pinboard_items.for_object(self.metamorphosize).any?
  end

  # @return [PinboardItem, nil]
  #   the pinboard item corresponding to the object, if present 
  def pinboard_item_for(user)
    user.pinboard_items.for_object(self.metamorphosize).first
  end

  # @return [Boolean]
  #   true if this item is set to be inserted 
  def inserted?(user)
    pinboard_item_for(user).try(:is_inserted)
  end

end
