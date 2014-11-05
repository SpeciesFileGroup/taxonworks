module Workbench::TimeHelper
  def object_time_since_creation_tag(object)
    time_ago_in_words(object.created_at)
  end

  def object_time_since_update_tag(object)
    time_ago_in_words(object.updated_at)
  end
end
