module Shared::IsData::Navigation
  extend ActiveSupport::Concern
 
  module ClassMethods
  end

  def base_navigation_next
    base_class = self.class.base_class
    base = base_class.order(id: :ASC).where(base_class.arel_table[:id].gt(id)).limit(1)
    return base.where(project_id: project_id) if respond_to?(:project_id)
    base
  end

  def base_navigation_previous
    base_class = self.class.base_class
    base = base_class.order(id: :DESC).where(base_class.arel_table[:id].lt(id)).limit(1)
    return  base.where(project_id: project_id) if respond_to?(:project_id)
    base
  end

  def next
    base_navigation_next.first
  end

  def previous
    base_navigation_previous.first
  end

  def next_by_created_at
    base_navigation_next.reorder(created_at: :asc).first
  end

  def previous_by_created_at
    base_navigation_previous.reorder(created_at: :desc).first
  end

  def next_by_user_created_at(user_id)
    base_navigation_next.where(created_by_id: user_id).reorder(created_at: :asc).first
  end

  def previous_by_user_created_at(user_id)
    base_navigation_previous.where(created_by_id: user_id).reorder(created_at: :desc).first
  end

end
