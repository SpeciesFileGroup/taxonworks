module HubHelper

  def task_card(task)
    content_tag(:div, '', class: 'task_card') { 
      content_tag(:div,'' , class: 'task_header') {
        content_tag(:div, task.status, class: "status #{task.status}") +
        task.categories.collect{|c| 
          content_tag(:div, c.humanize, class: "categories #{c}") # @josé icon injected in here, switch div to img tag.
        }.join().html_safe  
      } +
      content_tag(:div, task.name, class: 'task_name') +
      content_tag(:div, task.description, class: 'task_description') 
    }
  end

  def data_card(data)
    content_tag(:div, class: :data_card) do  
      content_tag(:div, "", 
                  data.categories.inject({}){|hsh,c| hsh.merge!("data-category-#{c}" => "true") }.merge( class: "status #{data.status}") 
                 ) + 
        link_to(data.name, data.klass)
    end
  end

end

