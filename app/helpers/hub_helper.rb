module HubHelper

  # TODO FIX ON Turbolinks 5.0
  def task_card(task)
    return nil if task.nil?
    content_tag(:div, '', class: 'task_card') { 
      link_to(content_tag(:div,
        content_tag(:div,'' , class: "task_header status #{task.status}") {

          task.categories.collect{|c| 
            content_tag(:div, c.humanize, title: c.humanize, class: "categories #{c}", "data-category-#{c}" => 'true', "data-category-#{task.status}" => 'true' )
          }.join().html_safe 

        } +      
        content_tag(:div, '', class: 'task-information') {
          content_tag(:div, task.name, class: 'task_name') +
          content_tag(:div, task.description, class: 'task_description') 
        }, class: 'task-content'
      ),send(task.path), data: { turbolinks: false }, tabindex: 0) +
      content_tag(:div, '', class: 'fav-link') {
        favorite_page_link('tasks', task.prefix) 
      }       
    }
  end

  # @return [Array]
  #   the task prefixes the current user has favorited in this project
  def hub_favorite_tasks
    return [] unless has_hub_favorites?

    sessions_current_user.hub_favorites[sessions_current_project_id.to_s]['tasks'] || []
  end

  def hub_json
    return  {
      tasks: UserTasks.hub_tasks.inject([]){|ary, t| ary.push(t.to_h.merge(path: send(t.path))) ; ary},
      data: Hub::Data::CONFIG_DATA,
      favourites: sessions_current_user.hub_favorites[sessions_current_project_id.to_s]
    }
  end

  def data_link(data)
    link_to(data.name, data.klass, tabindex: 0)
  end

  def hub_category_icon(category)
    paths = {
      'filters'           => '<polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"/>',
      'browse'            => '<circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/>',
      'new'               => '<path d="M5 12h14"/><path d="M12 5v14"/>',
      'nomenclature'      => '<path d="M12.586 2.586A2 2 0 0 0 11.172 2H4a2 2 0 0 0-2 2v7.172a2 2 0 0 0 .586 1.414l8.704 8.704a2.426 2.426 0 0 0 3.42 0l6.58-6.58a2.426 2.426 0 0 0 0-3.42z"/><circle cx="7.5" cy="7.5" r=".5" fill="currentColor"/>',
      'source'            => '<path d="M12 7v14"/><path d="M3 18a1 1 0 0 1-1-1V4a1 1 0 0 1 1-1h5a4 4 0 0 1 4 4 4 4 0 0 1 4-4h5a1 1 0 0 1 1 1v13a1 1 0 0 1-1 1h-6a3 3 0 0 0-3 3 3 3 0 0 0-3-3z"/>',
      'collection_object' => '<path d="m8 2 1.88 1.88"/><path d="M14.12 3.88 16 2"/><path d="M9 7.13v-1a3.003 3.003 0 1 1 6 0v1"/><path d="M12 20c-3.3 0-6-2.7-6-6v-3a4 4 0 0 1 4-4h4a4 4 0 0 1 4 4v3c0 3.3-2.7 6-6 6"/><path d="M12 20v-9"/><path d="M6.53 9C4.6 8.8 3 7.1 3 5"/><path d="M6 13H2"/><path d="M3 21c0-2.1 1.7-3.9 3.8-4"/><path d="M20.97 5c0 2.1-1.6 3.8-3.5 4"/><path d="M22 13h-4"/><path d="M17.2 17c2.1.1 3.8 1.9 3.8 4"/>',
      'collecting_event'  => '<path d="M20 10c0 6-8 12-8 12s-8-6-8-12a8 8 0 0 1 16 0Z"/><circle cx="12" cy="10" r="3"/>',
      'biology'           => '<path d="M11 20A7 7 0 0 1 9.8 6.1C15.5 5 17 4.48 19 2c1 2 2 4.18 2 8 0 5.5-4.78 10-10 10Z"/><path d="M2 21c0-3 1.85-5.36 5.08-6"/>',
      'matrix'            => '<rect width="18" height="18" x="3" y="3" rx="2"/><path d="M3 9h18"/><path d="M3 15h18"/><path d="M9 3v18"/><path d="M15 3v18"/>',
      'dna'               => '<path d="M2 15c6.667-6 13.333 0 20-6"/><path d="M9 22c1.798-1.998 2.518-3.995 2.807-5.993"/><path d="M15 2c-1.798 1.998-2.518 3.995-2.807 5.993"/><path d="m17 6-2.891-2.891"/><path d="m10 16 1.5 1.5"/><path d="m14 8-1.5-1.5"/><path d="m7 18 2.891 2.891"/><path d="m20 9 .891.891"/><path d="m6.5 12.5 1 1"/><path d="m16.5 10.5 1 1"/>',
      'image'             => '<rect width="18" height="18" x="3" y="3" rx="2" ry="2"/><circle cx="9" cy="9" r="2"/><path d="m21 15-3.086-3.086a2 2 0 0 0-2.828 0L6 21"/>'
    }
    inner = paths[category.to_s] || '<circle cx="12" cy="12" r="9"/>'
    content_tag(:svg, inner.html_safe,
                xmlns: 'http://www.w3.org/2000/svg', width: 16, height: 16,
                viewBox: '0 0 24 24', fill: 'none', stroke: 'currentColor',
                'stroke-width' => 2, 'stroke-linecap' => 'round',
                'stroke-linejoin' => 'round', class: 'category-icon')
  end

  def data_card(data)
    content_tag(:div, class: 'data_card') do  
      content_tag(:div, '') +
      content_tag(:div, '', 
                  data.categories.inject({}){|hsh,c| hsh.merge!("data-category-#{c}" => 'true') }.merge(class: [:filter_data, :middle, 'card-categories', "#{data.status}", data.shared_css, data.application_css].flatten.join(' '), title: data.categories.map{|c| c.humanize}.join(', '), "data-category-#{data.status}" => 'true')
                 ) + 
        data_link(data) +
      content_tag(:div, '', class: 'fav-link') {
        favorite_page_link('data', data.klass.to_s)
      }
    end
  end

end

