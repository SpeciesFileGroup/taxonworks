# Methods for 1) generating paths; or 2) generating links.
module Workbench::NavigationHelper

  def quick_bar
    render(partial: '/workbench/navigation/quick_bar')  if sessions_current_project 
  end

  def quick_bar_link(related_model)
    model = Hub::Data::BY_NAME[ related_model.kind_of?(Hash) ? related_model.keys.first : related_model ]
    return nil if model.nil?
    content_tag(:li, data_link(model))
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

    link_object.nil? ? content_tag(:div,content_tag(:span,text, 'class' => 'small-icon', 'data-icon' => 'arrow-left'), 'class' => 'navigation-item disable') : link_to(content_tag(:span,text, 'data-icon' => 'arrow-left', 'class' => 'small-icon'), link_object.metamorphosize, 'data-arrow' => 'back', 'class' => 'navigation-item')
  end

  # A next record link.
  def next_link(instance)
    text = 'Next'
    if instance.respond_to?(:project_id)
      link_object = instance.class.base_class.order(id: :asc).with_project_id(instance.project_id).where(['id > ?', instance.id]).limit(1).first
    else
      link_object = instance.class.base_class.order(id: :asc).where(['id > ?', instance.id]).limit(1).first
    end
    link_object.nil? ? content_tag(:div,content_tag(:span,text, 'class' => 'small-icon icon-right', 'data-icon' => 'arrow-right'), 'class' => 'navigation-item disable') : link_to(content_tag(:span,text, 'data-icon' => 'arrow-right', 'class' => 'small-icon icon-right'), link_object.metamorphosize, 'data-arrow' => 'next', 'class' => 'navigation-item')
  end

  def new_path_for_model(model)
    send("new_#{model.name.tableize.singularize}_path")
  end

  def list_path_for_model(model)
    url_for(controller: model.name.tableize.pluralize.downcase, action: :list)
  end

  def new_for_model_link(model)
    if %w{Note Tag Citation Identifier DataAttribute AlternateValue GeographicArea ContainerItem}.include?(model.name)
      nil
    else
      link_to('New', new_path_for_model(model), 'data-icon' => 'new')
    end
  end

  def list_for_model_link(model)
    if model.any?
    link_to('List', list_path_for_model(model), 'data-icon' => 'list')
    else
     content_tag(:span, 'List', class: :disabled, 'data-icon' => 'list')
    end
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
    klass_name = object.class.base_class.name.underscore
    link_method = klass_name + '_link'

    # if a customized link to method is available use that, otherwise use a generic
    if self.respond_to?(link_method)
      send(link_method, object)
    else 
      t = object_tag(object)
      return "Unable to link to data #{object.class.name} id:#{object.id}." if t.blank?
      link_to(t.html_safe, metamorphosize_if(object))
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
      link_to(content_tag(:span, 'Edit', 'data-icon' => 'edit', class: 'small-icon'), edit_object_path(metamorphosize_if(object)), class: 'navigation-item')
    else
      content_tag(:div, content_tag(:span, 'Edit', 'data-icon' => 'edit', class: 'small-icon'), class: 'navigation-item disable')
    end
  end

  def destroy_object_link(object)
    if (!@sessions_current_user.is_administrator?) && (@is_shared_data_model)
      content_tag(:div, content_tag(:span, 'Destroy', 'data-icon' => 'trash', class: 'small-icon'), class: 'navigation-item disable')
    else
      link_to(content_tag(:span, 'Destroy', 'data-icon' => 'trash', class: 'small-icon'), object.metamorphosize, method: :delete, data: {confirm: 'Are you sure?'}, class: 'navigation-item')
    end
  end

  def batch_load_link
    if self.controller.respond_to?(:batch_load) 
      link_to('Batch load', { action: :batch_load, controller: self.controller_name } ,'data-icon' => 'batch') 
    else 
      content_tag(:span, 'Batch load', class: 'disabled', 'data-icon' => 'batch') 
    end
  end

  def annotate_links(object: nil)
    [content_tag(:li, add_alternate_value_link(object: object)),
     content_tag(:li, add_citation_link(object: object)),
     content_tag(:li, add_data_attribute_link(object: object)),
     content_tag(:li, add_identifier_link(object: object)),
     content_tag(:li, add_note_link(object: object)),
     content_tag(:li, add_tag_link(object: object))
    ].compact.join('').html_safe
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
  def related_data_link_tag(object)
    return nil if object.nil?
    p = "related_#{member_base_path(metamorphosize_if(object))}_path"
    content_tag(:li, link_to('Overview', send(p, object))) if controller.respond_to?(p)
  end

end
