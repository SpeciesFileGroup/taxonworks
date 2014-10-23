module PinboardItemsHelper

  def pin_item_to_pinboard_link(object, user)
    if !object.pinned?(user)
      link_to('Add to pinboard', pinboard_items_path(pinboard_item: {pinned_object_id: object.id, pinned_object_type: object.metamorphosize.class.name}), method: :post)
    else
      content_tag(:em, 'this record is pinned!')
    end
  end

end
