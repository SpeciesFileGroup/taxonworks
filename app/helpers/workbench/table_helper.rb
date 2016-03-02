# Helpers for table rendering
module Workbench::TableHelper

  def fancy_th_tag(filter: nil, group: nil, name: '')
    content_tag(:th, class: 'headerTableOptions', data: {filter: filter, group: group}) do
        content_tag(:span, name)
    end
  end

end
