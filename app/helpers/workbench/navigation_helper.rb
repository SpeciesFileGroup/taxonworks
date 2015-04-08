# Methods for 1) generating paths; or 2) generating links.
module Workbench::NavigationHelper


  def quick_bar
    render(partial: '/workbench/navigation/quick_bar') if is_data_controller?
  end

  def task_bar
    render(partial: '/workbench/navigation/task_bar') if is_task_controller?
  end

  def forward_back_links(instance)
    content_tag(:span, (previous_link(instance) + ' | ' + next_link(instance)).html_safe)
  end

  # A previous record link. 
  def previous_link(instance)
    text = 'Previous'
    if instance.respond_to?(:project_id)
      link_object = instance.class.base_class.order(id: :desc).with_project_id(instance.project_id).where(['id < ?', instance.id]).limit(1).first
    else
      link_object = instance.class.base_class.order(id: :desc).where(['id < ?', instance.id]).limit(1).first
    end

    link_object.nil? ? text : link_to(text, link_object.metamorphosize)
  end

  # A next record link.
  def next_link(instance)
    text = 'Next'
    if instance.respond_to?(:project_id)
      link_object = instance.class.base_class.order(id: :asc).with_project_id(instance.project_id).where(['id > ?', instance.id]).limit(1).first
    else
      link_object = instance.class.base_class.order(id: :asc).where(['id > ?', instance.id]).limit(1).first
    end
    link_object.nil? ? text : link_to(text, link_object.metamorphosize)
  end

  def new_path_for_model(model)
    send("new_#{model.name.tableize.singularize}_path")
  end

  def list_path_for_model(model)
    send("list_#{model.name.tableize}_path")
  end

  def new_for_model_link(model)
    if model.annotates?
      nil
    else
      link_to('new', new_path_for_model(model))
    end
  end

  def list_for_model_link(model)
    link_to('list', list_path_for_model(model))
  end

  def download_for_model_link(model)
    if self.controller.respond_to?(:download)
      link_to('download', download_path_for_model(model))
    else
      content_tag(:em, 'Download not yet available.')
    end
  end

  def download_path_for_model(model)
    send("download_#{model.name.tableize}_path")
  end

  def object_link(object)
    return nil if object.nil?
    link_to(object_tag(object).html_safe, object.metamorphosize)
  end

  def edit_object_path(object)
    send(edit_object_path_string(object), object)
  end

  def edit_object_path_string(object)
    "edit_#{object.class.base_class.name.underscore}_path"
  end

  def edit_object_link(object)
    # TODO  We need to think more about what the rules will be to allow editing on shared objects.
    # currently this is only allows the creator to edit a shared object.
    if (!@sessions_current_user.is_administrator?) && ((@is_shared_data_model && object.created_by_id != $user_id)||
      !self.respond_to?(edit_object_path_string(object)) )
      content_tag(:span, 'Edit', class: :disabled)
    else
      link_to('Edit', edit_object_path(object.metamorphosize))
    end
  end

  def destroy_object_link(object)
    if (!@sessions_current_user.is_administrator?) && (@is_shared_data_model)
      content_tag(:span, 'Destroy', class: :disabled)
    else
      link_to('Destroy', object.metamorphosize, method: :delete, data: {confirm: 'Are you sure?'})
    end
  end

  def batch_load_link
    if self.controller.respond_to?(:batch_load) 
      link_to('batch load', action: :batch_load, controller: self.controller_name) 
    else 
      content_tag(:span, 'batch load', class: 'disabled') 
    end
  end

  def annotate_links(object: object)
    [add_alternate_value_link(object: object),
     add_citation_link(object: object),
     add_data_attribute_link(object: object),
     add_identifier_link(object: object),
     add_note_link(object: object),
     add_tag_link(object: object)
    ].compact.join('<br>').html_safe
  end


  def safe_object_from_attributes(hsh)
    if hsh['object_type'] && hsh['object_type']
      begin
        return hsh['object_type'].constantize.find(hsh['object_id'])
      rescue ActiveRecord::RecordNotFound
        return false 
      end
    end
    nil
  end

  def recent_route_link(hsh)
    route = hsh.keys.first
    o = safe_object_from_attributes(hsh[route])
    if o.nil?
      link_to(route.parameterize(' - ').humanize.capitalize, route)
    elsif o
      o = o.metamorphosize if o.respond_to?(:metamorphosize)
      link_to(object_tag(o) +  " [#{hsh[route]['object_type']}]" , route) 
    else
      content_tag(:em, 'Data no longer available.', class: :warning)
    end
  end

end
