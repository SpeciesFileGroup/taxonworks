# Generic wrappers around AR instances, these should not include link generation, but may call out to other helpers that do generate links. 
#
module Workbench::DisplayHelper
  # General wrapper around individual <model_name>_tag methods
  #   object_tag(@otu) 
  def object_tag(object)
    return nil if object.nil?
    method = object_tag_method(object)

    # meh, exceptions  
    return send("taxon_works_content_tag", object).html_safe if method == 'content_tag' 
    return image_tag(object.image_file.url(:thumb)) if method == 'image_tag' 

    if self.respond_to?(method)
      html = send(method, object)
      html ? html.html_safe : nil
    else
      nil #  content_tag(:span,"#{object.class} has no helper method '#{method}'", class: :warning)
    end
  end

  def object_tag_method(object)
    return nil if object.nil?
    klass_name = object.class.name
    method = "#{klass_name.underscore.gsub('/', '_')}_tag"
    if ApplicationController.helpers.respond_to?(method)
      method
    else
      klass_name = metamorphosize_if(object).class.name
      "#{klass_name.underscore}_tag"
    end
  end

  def model_name_title
    controller_name.humanize
  end

  def kind(object)
    object.class.name.humanize
  end

  def object_attributes_partial_path(object)
    "/#{metamorphosize_if(object).class.base_class.name.tableize}/attributes"
  end

  def object_card_partial_path(object)
    '/' + object_class_name(object) + '/card'
  end

  def object_class_name(object)
    object.class.base_class.name.tableize.to_s
  end

end
