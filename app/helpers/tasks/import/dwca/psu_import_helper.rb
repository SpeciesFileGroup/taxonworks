module Tasks::Import::Dwca::PsuImportHelper

  def text_row(row)
    color  = 'green'
    color  = 'red' unless row[:err].blank?
    output = "<li class=#{color}>"
    output += (row[:row].to_s)
    # output += ((ap row[:row]))
    # output += ((ap row[:row_objects][:make_ce]))
    # output += ap(row[:row_objects][:make_ce])
    unless row[:warn].blank?
      row[:warn].each do |warning|
        output += content_tag(:ul, content_tag(:li, warning, class: 'brown'))
      end
    end
    unless row[:err].blank?
      row[:err].each do |error|
        output += content_tag(:ul, content_tag(:li, error, class: 'red'))
      end
    end
    output += '</li>'
    output.html_safe
  end

  # @return [String]
  #   short string of use in autocomplete selects
  def collection_object_namespace_select_tag
    select_tag(:dwca_namespace, options_for_select(Namespace.pluck(:short_name).uniq), prompt: 'Select a namespace')
  end

end
