# Shared code pinning objects (adding them to your pinboard). 
#
module Shared::IsData::Pinnable
  extend ActiveSupport::Concern

  included do
    has_many :pinboard_items, as: :pinned_object, dependent: :destroy
  
    scope :pinned_by, -> (user_id) { joins(:pinboard_items).where(pinboard_items: {user_id: user_id}) } 
    scope :pinboard_inserted, -> { joins(:pinboard_items).where(pinboard_items: {is_inserted: true}) }
    scope :pinned_in_project, -> (project_id) { joins(:pinboard_items).where(pinboard_items: {project_id: project_id})} 
  end

  # @return [Boolean]
  #   whether the object is pinned by the user 
  def pinned?(user, project_id)
    if pinboard_items.loaded?
      !!pinboard_items.detect { |i| i.project_id == project_id && i.user_id == user.id }
    else
      user && user.pinboard_items.where(project_id: project_id).for_object(self.metamorphosize).any?
    end
  end

  # @return [PinboardItem, nil]
  #   the pinboard item corresponding to the object, if present 
  def pinboard_item_for(user)
    return nil unless user
    if pinboard_items.loaded?
      pinboard_items.detect { |i| i.user_id == user.id }
    else
      pinboard_items.where(user_id: user.id).for_object(self.metamorphosize).first
    end
  end

  # @return [Boolean]
  #   true if this item is set to be inserted 
  def inserted?(user)
    pinboard_item_for(user).try(:is_inserted)
  end

end
