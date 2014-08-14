class PinboardItem < ActiveRecord::Base
  include Housekeeping

  acts_as_list scope: [:project_id, :pinned_object_type]

  belongs_to :user
  belongs_to :pinned_object, polymorphic: true

  before_validation :validate_is_inserted, :validate_is_cross_project
  validates_presence_of :pinned_object 

  def is_inserted?
    !is_inserted.blank?
  end

  def is_cross_project?
    !is_cross_project.blank?
  end

  def set_as_insertable
    PinboardItem.where(project_id: project_id, pinned_object_type: pinned_object_type).each do |p|
      p.update(is_inserted: false)
    end
    update(is_inserted: true)
  end

  protected

  def validate_is_inserted 
    errors.add(:is_inserted, 'only one item per type can be inserted automatically') if is_inserted? && PinboardItem.where(is_inserted: true, pinned_object_type: pinned_object.class.to_s, project_id: $project_id).reload.count > 0
  end

  def validate_is_cross_project
    errors.add(:is_cross_project, 'model is not a cross project model') if is_cross_project? && !pinned_object.class.ancestors.map(&:name).include?('Shared::SharedAcrossProjects')
  end

end
