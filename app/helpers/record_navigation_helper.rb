# An interface implemented by model helpers requiring previous/next/parents
# navigation links.
module RecordNavigationHelper
  # @return [Object] An object implementing the helper methods from
  # <model>Helper.
  def self.for(model_name)
    helper_module = "#{model_name.pluralize}Helper".constantize # can explode
    return Object.new.extend(helper_module)
  end

  # @return Array
  def parent_records(object)
    []
  end

  # @return !!Array!!
  def previous_records(object)
    o = object.class
      .where(project_id: object.project_id)
      .where('id < ?', object.id)
      .order(id: :desc)
      .first

    [o].compact
  end

  # @return !!Array!!
  def next_records(object)
    o = object.class
      .where(project_id: object.project_id)
      .where('id > ?', object.id)
      .order(:id)
      .first

    [o].compact
  end
end