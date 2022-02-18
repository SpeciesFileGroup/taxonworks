# Methods for 1) generating paths; or 2) generating links
# For helper methods that return individual instances based on some parameters see corresponding
# helpers.
module Workbench::NavigationHelper
  
  NO_NEW_FORMS = %w{Confidence Attribution ObservationMatrixRow ObservationMatrixColumn Note Tag
  Citation Identifier DataAttribute AlternateValue
  GeographicArea ContainerItem ProtocolRelationship Download}.freeze

  NOT_DATA_PATHS = %w{/project /administration /user}.freeze

  # Slideout panels
  def slideouts
    if sessions_current_project && sessions_signed_in? && on_workbench?
      [ slideout_pinboard,
      slideout_pdf_viewer,
      slideout_clipboard ].join.html_safe
    end
  end

  def slideout_clipboard
    render(partial: '/shared/data/slideout/clipboard')
  end

  def slideout_pinboard
    render(partial: '/shared/data/slideout/pinboard')
  end

  def slideout_recent
    render(partial: '/shared/data/slideout/recent')
  end

  def slideout_pdf_viewer
    render(partial: '/shared/data/slideout/document')
  end

  # @return [Boolean]
  def on_workbench?
    !(request.path =~ /#{NOT_DATA_PATHS.join('|')}/)
  end

  def quick_bar
    render(partial: '/workbench/navigation/quick_bar')  if sessions_signed_in?
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

  # Used in show/REST
  # A previous record link.
  def previous_link(instance, text: 'Previous', target: nil)
    link_text = content_tag(:span, text,  'data-icon' => 'arrow-left', 'class' => 'small-icon')
    link_object = instance.previous
    return content_tag(:div, link_text, 'class' => 'navigation-item disable') if link_object.nil?
    if target.nil?
      target ||= link_object.metamorphosize
    else
      target = send(target, id: link_object.id)
    end
    link_to(link_text, target, 'data-arrow' => 'back', 'class' => 'navigation-item')
  end

  # Used in show/REST
  # A next record link.
  def next_link(instance, text: 'Next', target: nil)
    link_text = content_tag(:span, text, 'class' => 'small-icon icon-right', 'data-icon' => 'arrow-right')
    link_object = instance.next
    return content_tag(:div, link_text, 'class' => 'navigation-item disable') if link_object.nil?
    if target.nil?
      target ||= link_object.metamorphosize
    else
      target = send(target, id: link_object.id)
    end
    link_to(link_text, target, 'data-arrow' => 'next', 'class' => 'navigation-item')
  end

  def new_path_for_model(model)
    send("new_#{model.name.tableize.singularize}_path")
  end

  def list_path_for_model(model)
    url_for(controller: model.name.tableize.pluralize.downcase, action: :list)
  end

  def new_for_model_link(model)
    if NO_NEW_FORMS.include?(model.name)
      nil
    elsif model.name == 'ProjectSource'
      link_to('New', new_source_path, 'class' => 'small-icon', 'data-icon' => 'new')
    else
      link_to(content_tag(:span, 'New', 'class' => 'small-icon', data: { icon: :new }), new_path_for_model(model), 'class' => 'navigation-item')
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
      link_to('Download', download_path_for_model(model), data: { icon: :download, turbolinks: false })
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

    # If a customized link to method is available use that, otherwise use a generic
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

  # Determine wether an edit or destroy route exists
  # Custom routes can be added per Class by adding
  # a corresponding `_string` postfixed method.
  # @return String
  def edit_object_path_string(object)
    default  = "edit_#{metamorphosize_if(object).class.base_class.name.underscore}_path"
    specific = default + '_string'
    if self.respond_to?(specific)
      self.send(specific, object)
    else
      default
    end
  end

  # return [Boolean]
  #   true if there is a route to edit for the object (some objects are not editable, like Tags)
  def has_route_for_edit?(object)
    self.respond_to?(edit_object_path_string(object))
  end

  # return [Boolean]
  #   true if there is a route to edit for the object (some objects are not editable, like Tags)

  # return [A tag, nil]
  #   a link, or disabled link
  def edit_object_link(object)
    if has_route_for_edit?(object) && object.is_editable?(sessions_current_user)
      link_to(content_tag(:span, 'Edit', 'data-icon' => 'edit', class: 'small-icon'), edit_object_path(metamorphosize_if(object)), class: 'navigation-item')
    else
      content_tag(:div, content_tag(:span, 'Edit', 'data-icon' => 'edit', class: 'small-icon'), class: 'navigation-item disable')
    end
  end

  def destroy_object_link(object)
    if object.is_destroyable?(sessions_current_user)
      link_to(content_tag(:span, 'Destroy', 'data-icon' => 'trash', class: 'small-icon'), object.metamorphosize, method: :delete, data: {confirm: 'Are you sure?'}, class: 'navigation-item')     
    else
      content_tag(:div, content_tag(:span, 'Destroy', 'data-icon' => 'trash', class: 'small-icon'), class: 'navigation-item disable')
    end
  end

  def batch_load_link
    if self.controller.respond_to?(:batch_load)
      link_to('Batch load', {action: :batch_load, controller: self.controller_name}, 'data-icon' => 'batch')
    else
      content_tag(:span, 'Batch load', class: 'disabled', 'data-icon' => 'batch')
    end
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
      link_to(route.parameterize(separator: ' - ').humanize.capitalize, route)
    elsif o
      o = o.metamorphosize if o.respond_to?(:metamorphosize)
      link_to(object_tag(o) + " [#{hsh[route]['object_type']}]", route)
    else
      content_tag(:em, 'Data no longer available.', class: :warning)
    end
  end

  # @return [<a> tag, nil]
  #   a link to the related data page
  def related_data_link_tag(object)
    return nil if object.nil?
    p = "related_#{member_base_path(metamorphosize_if(object))}_path"
    content_tag(:li, link_to('Related data', send(p, object))) if controller.respond_to?(p)
  end

  def a_to_z_links(targets = [])
    letters = targets.empty? ? ('A'..'Z') : ('A'..'Z').to_a & targets
    content_tag(:div, class: 'navigation-bar-left', id: 'alphabet_nav') do
      content_tag(:ul, class: 'left_justified_navbar context-menu') do
        letters.collect{|l| content_tag(:li, link_to("#{l}", "\##{l}")) }.join.html_safe
      end
    end
  end

  def title_tag
    splash = request.path =~ /task/ ? request.path.demodulize.humanize : request.path.split('/')&.second&.humanize
    content_tag(:title, ['TaxonWorks', splash].compact.join(' - ') )
  end

  def radial_navigation_tag(object)
    content_tag(:span, '', data: { 'global-id' => object.to_global_id.to_s, 'radial-object' => 'true'})
  end

  # If a "home" is provided, use it instead of show link
  # See also over ride in object_link - which we might need to merge
  def object_home_link(object)
    k = object.class
    klass = OBJECT_RADIALS[k.name] ? k.name : k.base_class.name

    p = OBJECT_RADIALS[klass]
    if p && p['home']
      link_to(
        object_tag(object),
        send("#{p['home']}_path", "#{klass.tableize.singularize}_id" => object.id)
      )
    else
      object_link(object)
    end
  end

end
