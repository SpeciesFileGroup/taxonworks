module PinboardItemsHelper

  def pin_item_to_pinboard_link(object, user)
    if !object.pinned?(user)
      link_to(content_tag(:span, '', class: 'pin-button', data: { "pin-item-id": object.id }), pinboard_items_path(pinboard_item: {pinned_object_id: object.id, pinned_object_type: object.metamorphosize.class.name}), class: 'navigation-item' , method: :post)
    else
      link_to('', pinboard_item_path(get_pinboard_item_form_object(object,user)), class: 'unpin-button', data: { "pin-item-id": object.id }, method: :delete)
    end
  end

  def get_pinboard_item_form_object(object, user)
    if object.pinned?(user)
    	PinboardItem.where(pinned_object_id: object.id, user_id: user).first
    end
  end    

end
