module HubHelper

  def task_card(task)
    content_tag(:div, '', class: 'task_card') { 
      content_tag(:div,'' , class: 'task_header') {
        content_tag(:div, '', class: 'task-header-left') {
          content_tag(:div, task.status, class: "status #{task.status}")
        } +
        content_tag(:div, '', class: 'task-header-right') {
          task.categories.collect{|c| 
            content_tag(:div, c.humanize, class: "categories #{c}") # @josé icon injected in here, switch div to img tag.
          }.join().html_safe +
          favorite_page_link('tasks', task.prefix) 
        } 
      } +
      content_tag(:div, link_to(task.name, send(task.path) ), class: 'task_name') +
      content_tag(:div, task.description, class: 'task_description') 
    }
  end

  def data_card(data)
    content_tag(:div, class:  ['data_card', data.shared_css, data.application_css].flatten.join(' ')) do  
      content_tag(:div, "", 
                  data.categories.inject({}){|hsh,c| hsh.merge!("data-category-#{c}" => "true") }.merge( class: "status #{data.status}") 
                 ) + 
        link_to(data.name, data.klass)
    end
  end

end

