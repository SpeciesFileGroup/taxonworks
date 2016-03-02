# Helpers for table rendering
module Workbench::TableHelper

  def fancy_th_tag(filter: nil, group: nil, name: '')
    content_tag(:th, class: 'headerTableOptions', data: {filter: filter, group: group}) do
      link_to("#", class: 'headerSortUp') do
        content_tag(:span, name) +
          image_tag("/icons/arrow-up.svg", class: 'arrow_up' ).html_safe +  # might have to change reference to arrow_up to arrow_down, I think you can display an icon with a CSS class
          image_tag("/icons/arrow-down.svg", class: 'arrow_down').html_safe
      end
    end
  end

end
