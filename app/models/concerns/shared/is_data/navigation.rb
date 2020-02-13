module Shared::IsData::Navigation
  extend ActiveSupport::Concern
 
  module ClassMethods
  end

  def next
    base = self.class.base_class.order(id: :asc).where(['id > ?', id]).limit(1)
    if respond_to?(:project_id)
      base.with_project_id(project_id).first
    else
      base.first
    end
  end

  def previous
    base = self.class.base_class.order(id: :desc).where(['id < ?', id]).limit(1)
    if respond_to?(:project_id)
      base.with_project_id(project_id).first
    else
      base.first
    end
  end

end
