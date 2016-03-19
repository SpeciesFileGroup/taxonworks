module Plugins::PapertrailHelper

  def paper_trail_version_tag(paper_trail_version)
    return nil if paper_trail_version.nil?
    "Revision #{paper_trail_version.index}" 
  end

  def papertrail_link_tag(object)
    content_tag(:li, link_to('Papertrail', papertrail_path(object_type: object.class, object_id: object.id))) if object.respond_to?(:versions) 
  end

end
