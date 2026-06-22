# Helpers for table rendering
module Workbench::TableHelper

  def row_action_icon(name)
    icon(name, size: 15)
  end

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

  # A single visible cell with the row's actions (show / edit / delete),
  # replacing the former hidden cells + right-click context menu.
  def fancy_options_cells_tag(object)
    content_tag(:td, class: 'row-actions') do
      safe_join([
        row_action_show_link(object),
        row_action_edit_link(object),
        row_action_delete_link(object)
      ].compact)
    end
  end

  def row_action_show_link(object)
    target = defined?(object.annotated_object) ? metamorphosize_if(object.annotated_object) : metamorphosize_if(object)
    link_to(row_action_icon('show'), target, class: 'row-action btn-tonal btn-primary', 'aria-label': 'Show record', data: { show: true, tooltip_content: 'Show record', tooltip_placement: 'bottom' })
  end

  def row_action_edit_link(object)
    return nil unless has_route_for_edit?(object)
    return nil if object.respond_to?(:is_editable?) && !object.is_editable?(sessions_current_user)
    link_to(row_action_icon('edit'), edit_object_path(metamorphosize_if(object)), class: 'row-action btn-tonal btn-primary', 'aria-label': 'Edit record', data: { tooltip_content: 'Edit record', tooltip_placement: 'bottom' })
  end

  def row_action_delete_link(object)
    m = metamorphosize_if(object)
    return nil unless m.respond_to?(:is_destroyable?) && m.is_destroyable?(sessions_current_user)
    link_to(row_action_icon('delete'), m, method: :delete, class: 'row-action btn-tonal btn-destroy', 'aria-label': 'Delete record', data: { confirm: 'Are you sure?', delete: true, tooltip_content: 'Delete record', tooltip_placement: 'bottom' })
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

  def copy_table_to_clipboard(selector, offset = 0, message = 'Copy to clipboard' )
    content_tag(:button, message , data: { 'clipboard-table-selector': selector, offset: }, type: 'button')
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

  # Almost certainly not DRY within TW
  def table_from_csv(csv, id: nil)
    return tag.table if csv.nil?
    s = "<table id=\"#{id}\">"
    csv.by_row.each do |r|
      s << tag.tr( r.fields.collect{|a| tag.td(a)}.join.html_safe)
    end
    s << '</table>'
    s.html_safe
  end

end
