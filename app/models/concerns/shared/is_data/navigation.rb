module Shared::IsData::Navigation
  extend ActiveSupport::Concern
 
  module ClassMethods
  end

  def base_navigation_next
    t = self.class.base_class.name.tableize
    base = self.class.base_class.order("#{t}.id ASC").where(["#{t}.id > ?", id]).limit(1)
    return base.with_project_id(project_id) if respond_to?(:project_id)
    base
  end

  def base_navigation_previous
    t = self.class.base_class.name.tableize
    base = self.class.base_class.order("#{t}.id DESC").where(["#{t}.id<> ?", id]).limit(1)
    return  base.with_project_id(project_id) if respond_to?(:project_id)
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
