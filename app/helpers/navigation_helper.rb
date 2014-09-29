# Methods for 1) generating paths; or 2) generating links.
module NavigationHelper

  def quick_bar
    render(partial: '/navigation/quick_bar') if is_data_controller?
  end

  def task_bar
    render(partial: '/navigation/task_bar') if is_task_controller?
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

    link_object.nil? ? text : link_to(text, link_object.becomes(link_object.class.base_class))
  end

  # A next record link.
  def next_link(instance)
    text = 'Next'
    if instance.respond_to?(:project_id)
      link_object = instance.class.base_class.order(id: :asc).with_project_id(instance.project_id).where(['id > ?', instance.id]).limit(1).first
    else
      link_object = instance.class.base_class.order(id: :asc).where(['id > ?', instance.id]).limit(1).first
    end
    link_object.nil? ? text : link_to(text, link_object.becomes(link_object.class.base_class))
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
    link_to(object_tag(object).html_safe, object.becomes(object.class.base_class))
  end

  def edit_object_path(object)
    send("edit_#{object.class.base_class.name.underscore}_path", object)
  end

  def edit_object_link(object)
    link_to('Edit', edit_object_path(object.becomes(object.class.base_class)))
  end

  def destroy_object_link(object)
    link_to('Destroy', object.becomes(object.class.base_class), method: :delete, data: { confirm: 'Are you sure?' })
  end


 def batch_preview_model_path
    send("batch_preview_#{controller_name.to_s.pluralize}_path")
  end

end
