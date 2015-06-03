# Generic wrappers around AR instances, these should not include link generation, but may call out to other helpers that do generate links. 
#
module Workbench::DisplayHelper

  # General wrapper around individual <model_name>_tag methods
  #   object_tag(@otu) 
  def object_tag(object)
    return nil if object.nil?
    klass_name = object.class.base_class.name

    # meh, exceptions  
    return send("taxon_works_content_tag", object).html_safe if klass_name == 'Content' 
    return image_tag(object.image_file.url(:thumb)) if klass_name == 'Image' 

    html = send("#{klass_name.underscore}_tag", object)
    html ? html.html_safe : nil
  end

  def model_name_title
    controller_name.humanize
  end

  def object_attributes_partial_path(object)
    "/#{object.class.base_class.name.tableize}/attributes"
  end
  
end
