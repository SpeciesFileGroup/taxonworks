# An interface implemented by model helpers requiring previous/next/parents
# navigation links.
# Users must add themselves to HELPER_MODULES_HASH.
module RecordNavigationHelper
  # TODO Make this go away if possible - currently it's used in place of
  # dynamically loading the correct helper module from its name (string).
  HELPER_MODULES_HASH = {
    BiologicalAssociation: BiologicalAssociationsHelper,
    Otu: OtusHelper,
  }

  # @return [Object] An object implementing the helper methods from
  # <model>Helper.
  def self.for(model_name)
    Object.new.extend(HELPER_MODULES_HASH[model_name.to_sym])
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