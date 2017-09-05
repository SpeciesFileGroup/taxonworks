module PinboardItemsHelper

  def pin_item_to_pinboard_link(object, user)
    if !object.pinned?(user)
      link_to('',  pinboard_items_path(pinboard_item: {pinned_object_id: object.id, pinned_object_type: object.metamorphosize.class.name}), data: { "pin-button-item-id": object.id }, class: 'navigation-item pin-button', remote: true, method: :post)
    else
      link_to('', pinboard_item_path(get_pinboard_item_form_object(object,user)), class: 'unpin-button', data: { "pin-button-item-id": object.id }, method: :delete, remote: true)
    end
  end

  def get_pinboard_item_form_object(object, user)
    if object.pinned?(user)
      PinboardItem.where(pinned_object_id: object.id, user_id: user).first
    end
  end 

  def pinboard_item_options(pinboard_item)
    options = [
      link_to('Remove', pinboard_item_path(pinboard_item), class: [ :remove, 'circle-button', 'button-delete' ], method: :delete) 
    ]
    options.push(source_document_viewer_option_tag(pinboard_item.pinned_object)) if pinboard_item.pinned_object.kind_of?(Source)

    if pinboard_item.is_inserted
      options.push link_to('Disable default', pinboard_item_path(pinboard_item: {id: pinboard_item.to_param, is_inserted: false}), class: [ ], method: :put, remote: true ) 
    else
      options.push link_to('Make default', pinboard_item_path(pinboard_item: {id: pinboard_item.to_param, is_inserted: true}), class: [ ],  method: :put, remote: true ) # <- new route here
    end

    content_tag(:div, class: 'itemOptions') do
      options.compact.join.html_safe
    end.html_safe
  end

  def pinboard_item_li_tag(pinboard_item)
    content_tag(:li, class: 'slide-panel-category-item', data: { pinboard_object_id: pinboard_item.pinned_object.id, insert: pinboard_item.is_inserted }, id: "order_#{pinboard_item.id}") do
      content_tag(:div, class: [:handle, 'flex-separate', :middle]) do
        object_link(pinboard_item.pinned_object) +  pinboard_item_options(pinboard_item)
      end
    end 
  end

end
