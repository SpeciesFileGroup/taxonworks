module Tasks::Import::Dwca::PsuImportHelper

  def text_roe(row)
    color  = 'green'
    color  = 'red' unless row[:err].blank?
    output = "<li class=#{color}>"
    output += row[:row].to_s
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
end
