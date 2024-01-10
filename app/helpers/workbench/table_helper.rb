# Helpers for table rendering
module Workbench::TableHelper

  def fancy_th_tag(group: nil, name: '')
    content_tag(:th, data: {group: group}) do
      content_tag(:span, name)
    end
  end

  # Hidden action links
  # data-attributes:
  #  data-show
  #  data-edit
  #  data-delete
  #
  # This is very important, it must be set to make work the options for the context menu.
  # Use the class ".table-options" to hide those options on the table
  #
  def fancy_metadata_cells_tag(object)
    content_tag(:td, object_tag(object.updater)) +
      content_tag(:td, object_time_since_update_tag(object)) +
      fancy_options_cells_tag(object)
  end

  def fancy_options_cells_tag(object)
    m = metamorphosize_if(object)
      fancy_show_tag(m) +
      fancy_edit_tag(m) + 
      fancy_pin_tag(m) +
      content_tag(:td, (link_to 'Destroy', m, method: :delete, data: {confirm: 'Are you sure?'}), class: 'table-options', data: {delete: true})
  end  

  def fancy_show_tag(object)
    defined?(object.annotated_object) ? 
      content_tag(:td, (link_to 'Show', metamorphosize_if(object.annotated_object)), class: 'table-options', data: {show: true}) :
      content_tag(:td, (link_to 'Show', object), class: 'table-options', data: {show: true})
  end

  def fancy_edit_tag(object)
    content_tag(:td, edit_object_link(object), class: 'table-options', data: {edit: true}) 
  end

  def fancy_pin_tag(object)
    if object.respond_to?(:pinned?)
      content_tag(:td, pin_item_to_pinboard_link(object, sessions_current_user), class: 'table-options', data: {pin: true})
    end
  end

  def copy_table_to_clipboard(selector)
    content_tag(:button, 'Copy to clipboard', data: { 'clipboard-table-selector': selector }, type: 'button')
  end

  def table_from_hash_tag(hash)
    tag.table do
      hash.collect do |k,v|
        tag.tr do
          concat(tag.td(k))
          concat(tag.td(tag.strong(v)))
        end
      end.join.html_safe
    end
  end

end
