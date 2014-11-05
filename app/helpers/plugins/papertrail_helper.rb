module Plugins::PapertrailHelper

  def papertrail_link(object)
    if object.respond_to?(:versions) 
      link_to('Papertrail', papertrail_path(object_type: object.class, object_id: object.id))
    else
      nil
    end
  end

end
