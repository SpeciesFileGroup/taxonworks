module PinboardItemsHelper

  def pin_item_to_pinboard_link(object, user)
    if !object.pinned?(user)
      link_to(content_tag(:span, 'Pin', class: 'pin-button'), pinboard_items_path(pinboard_item: {pinned_object_id: object.id, pinned_object_type: object.metamorphosize.class.name}), class: 'navigation-item' , method: :post)
    else
      content_tag(:span, 'Pinned', class: 'pin-button disable-button')
    end
  end

  def pinboard_item_options(pinboard_item)
    options = [
      link_to('Remove', pinboard_item_path(pinboard_item), class: :remove, method: :delete) 
    ]

    options.push(source_document_viewer_option_tag(pinboard_item.pinned_object)) if pinboard_item.pinned_object.kind_of?(Source)

    content_tag(:div, class: 'itemOptions') do
      options.compact.join.html_safe
    end.html_safe
  end
     
end
