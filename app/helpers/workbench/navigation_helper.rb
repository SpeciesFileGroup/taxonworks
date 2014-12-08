# Methods for 1) generating paths; or 2) generating links.
module Workbench::NavigationHelper


  def quick_bar
    render(partial: '/workbench/navigation/quick_bar') if is_data_controller?
  end

  def task_bar
    render(partial: '/workbench/navigation/task_bar') if is_task_controller?
  end

  def forward_back_links(instance)
    content_tag(:span,  (previous_link(instance) + ' | ' + next_link(instance)).html_safe )
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
    link_to('New', new_path_for_model(model)) 
  end 

  def list_for_model_link(model)
    link_to('List', list_path_for_model(model)) 
  end 

  def download_for_model_link(model)
    if self.controller.respond_to?(:download)
      link_to('Download', download_path_for_model(model)) 
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
    if @is_shared_data_model || !self.respond_to?(edit_object_path_string(object))
      content_tag(:span, 'Edit', class: :disabled) 
    else
      link_to('Edit', edit_object_path(object.metamorphosize))  
    end
  end

  def destroy_object_link(object)
    if @is_shared_data_model 
      content_tag(:span, 'Destroy', class: :disabled) 
    else
      link_to('Destroy', object.metamorphosize, method: :delete, data: { confirm: 'Are you sure?' })
    end
  end

  def batch_preview_model_path
    send("batch_preview_#{controller_name.to_s.pluralize}_path")
  end

  def annotate_links(object: object)
    [add_alternate_value_link(object: object),
     add_citation_link(object: object),
     add_identifier_link(object: object),
     add_note_link(object: object),
     add_tag_link(object: object)
    ].compact.join('<br>').html_safe
  end

end
