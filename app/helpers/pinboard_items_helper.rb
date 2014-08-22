module PinboardItemsHelper

  def pin_item_to_pinboard_link(object)
    link_to('Add to pinboard', pinboard_items_path(pinboard_item: {pinned_object_id: object.id, pinned_object_type: object.class.base_class.name}), method: :post) # needs becomes
  end

end
