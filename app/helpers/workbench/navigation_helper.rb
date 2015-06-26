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
    if %w{Note Tag Citation Identifier DataAttribute AlternateValue GeographicArea}.include?(model.name)
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
    klass_name = object.class.base_class.name.underscore
    link_method = klass_name + '_link'

    # if a customized link to method is available use that, otherwise use a generic
    if self.respond_to?(link_method)
      send(link_method, object)
    else
      link_to(object_tag(object).html_safe, metamorphosize_if(object))
    end
  end

  def edit_object_path(object)
    send(edit_object_path_string(object), object)
  end

  def edit_object_path_string(object)
    default = "edit_#{metamorphosize_if(object).class.base_class.name.underscore}_path"
    specific = default + '_string' 
    if self.respond_to?(specific)
      self.send(specific, object)
    else
      default 
    end
  end

  # return [Boolean]
  #   true if there is a route to edit for the object (some objects are not editable, like Tags)
  def is_editable?(object)
    self.respond_to?(edit_object_path_string(object))
  end

  # return [Boolean]
  #  true if the current user has permissions to edit the object in question (does not test whether it is actually editable)
  def user_can_edit?(object)
    @sessions_current_user.is_administrator? || user_is_creator?(object)
  end

  # return [Boolean]
  #  true if the current user created this object
  def user_is_creator?(object)
    object.created_by_id == $user_id
  end

  # return [A tag, nil]
  #   a link, or disabled link
  def edit_object_link(object)
    if is_editable?(object) && user_can_edit?(object)
      link_to('Edit', edit_object_path(metamorphosize_if(object)))
    else
      content_tag(:span, 'Edit', class: :disabled)
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

  # @return [<a> tag, nil] 
  #   a link to the related data page
  def related_data_link(object)
    return nil if object.nil?
    link_to('Related', send("related_#{base_path(metamorphosize_if(object))}_path", object)) 
  end

  # @return [String]
  #   the member path base for the object, object should be metamorphosized before passing.
  def base_path(object)
    object.class.name.tableize.singularize
  end




end
