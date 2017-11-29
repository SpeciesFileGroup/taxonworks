# Shared code pinning objects (adding them to your pinboard). 
#
module Shared::IsData::Pinnable
  extend ActiveSupport::Concern

  included do
    # include Users
    has_many :pinboard_items, as: :pinned_object, dependent: :destroy
  end

  # @return [Boolean]
  #   whether the object is pinned by the user
  def pinned?(user)
    user.pinboard_items.for_object(self.metamorphosize).count > 0
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
