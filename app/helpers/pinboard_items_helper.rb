module PinboardItemsHelper

  def pin_item_to_pinboard_link(object, user)
    if !object.pinned?(user, sessions_current_project_id)
      link_to('',  pinboard_items_path(pinboard_item: { pinned_object_id: object.id, pinned_object_type: object.metamorphosize.class.name, is_inserted: true }), data: { "pin-button-item-id": object.id }, class: 'navigation-item pin-button', remote: true, method: :post)
    else
      link_to('', pinboard_item_path(get_pinboard_item_form_object(object,user)), class: 'unpin-button', data: { "pin-button-item-id": object.id }, method: :delete, remote: true)
    end
  end

  def insert_pinboard_item_link(pinboard_item)
    if pinboard_item.is_inserted
      link_to('Disable default', pinboard_item_path(pinboard_item, pinboard_item: {is_inserted: false}), title: 'Disable default', class: ['circle-button', 'button-pinboard-default', 'button-delete', 'option-default'], method: :put, remote: true ) 
    else
      link_to('Make default', pinboard_item_path(pinboard_item, pinboard_item: {is_inserted: true}), title: 'Make default', class: ['circle-button', 'button-pinboard-default','button-submit', 'option-default'], method: :put, remote: true )
    end
  end

  # TODO: remove user?  use sessions user?
  def get_pinboard_item_form_object(object, user)
    if object.pinned?(user, sessions_current_project_id)
      PinboardItem.where(pinned_object_id: object.id, user_id: user).first
    end
  end 

  def pinboard_item_options(pinboard_item)
    options = [
      link_to('Remove', pinboard_item_path(pinboard_item), class: [ :remove, 'circle-button', 'button-delete' ], method: :delete, remote: true),
      insert_pinboard_item_link(pinboard_item)
    ]
    options.unshift(source_document_viewer_option_tag(pinboard_item.pinned_object)) if pinboard_item.pinned_object.kind_of?(Source)

    content_tag(:div, class: ['pinboard-dropdown']) do
      content_tag(:div, '', class: ['pinboard-menu-bar']) + 
        content_tag(:div, '', class: ['pinboard-menu-bar']) + 
        content_tag(:div, '', class: ['pinboard-menu-bar']) +
        content_tag(:div, class: [ 'itemOptions', 'pinboard-dropdown-content']) do
          options.compact.join.html_safe
        end
    end.html_safe
  end

  def pinboard_item_li_tag(pinboard_item)
    content_tag(:li, class: 'slide-panel-category-item', id: "order_#{pinboard_item.id}", data: { pinboard_object_id: pinboard_item.pinned_object.id, pinboard_item_id: pinboard_item.id, insert: pinboard_item.is_inserted }) do
      content_tag(:div, class: [:handle, 'flex-separate', :middle]) do
        object_home_link(pinboard_item.pinned_object) + pinboard_item_options(pinboard_item)
      end
    end 
  end

  # Session related helpers

  # @return [Integer, false]
  #   if there is an insertable pinboard for the item, that ID, otherwise false
  def inserted_pinboard_item_object_for_klass(klass)
    object = klass.constantize.joins(:pinboard_items).where(project_id: sessions_current_project_id, pinboard_items: {user_id: sessions_current_user_id, is_inserted: true}).first
    object ? object : false
  end

end
