# Shared code pinning objects (adding them to your pinboard). 
#
module Shared::IsData::Pinnable
  extend ActiveSupport::Concern

  included do
    # include Users
    has_many :pinboard_items, as: :pinned_object, dependent: :destroy
  end

  def pinned?(user)
    user.pinboard_items.for_object(self.metamorphosize).count > 0
  end

  def pinboard_item_for(user)
    user.pinboard_items.for_object(self.metamorphosize).first
  end

end
