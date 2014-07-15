module NavigationHelper

  def quick_bar
    render(partial: '/navigation/quick_bar') if is_data_controller?
  end

  def task_bar
    render(partial: '/navigation/task_bar') if is_task_controller?
  end



  def new_path_for_model(model)
    send("new_#{model.name.downcase}_path")
  end

  def list_path_for_model(model)
    send("list_#{model.class.name.tableize}_path")
  end

  def new_for_model_link(model)
    link_to('New', new_path_for_model(model)) 
  end 

  def list_for_model_link(model)
    link_to('List', list_path_for_model(model)) 
  end 

  def download_for_model_link(model)
    link_to('Download', download_path_for_model(model)) 
  end

  def download_path_for_model(model)
    send("download_#{model.name.tableize}_path")
  end

  def object_link(object)
    return nil if object.nil?
    link_to(object_tag(object), object)
  end

  # TODO: Move somewhere-else, all object methods are likely borked for subclasses.
  def object_tag(object)
    return content_tag(:em, 'None') if object.nil?
    send("#{object.class.name.underscore}_tag", object)
  end

  def edit_object_path(object)
    send("edit_#{object.class.name.underscore}_path", object)
  end

  def edit_object_link(object)
    link_to('Edit', edit_object_path(object))
  end


end
