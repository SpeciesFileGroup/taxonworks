# Generic wrappers around AR instances, these should not include link generation, but may call out to other helpers that do generate links. 
#
module Workbench::DisplayHelper

  # General wrapper around individual <model_name>_tag methods
  #   object_tag(@otu) 
  def object_tag(object)
    return nil if object.nil? 
    return send("taxon_works_content_tag", object).html_safe if object.class.base_class.name == 'Content' # Ugh, I hate this exception
    send("#{object.class.base_class.name.underscore}_tag", object).html_safe
  end

  def model_name_title
    controller_name.humanize.titleize
  end

  def object_attributes_partial_path(object)
    "/#{object.class.base_class.name.tableize}/attributes"
  end
  
end
