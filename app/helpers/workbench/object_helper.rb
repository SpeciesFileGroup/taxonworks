# A metamodule- helper methods for object related manipulations in other helpers
module Workbench::ObjectHelper

  # @return [ActiveRecord object]
  #   metamorphosize is defined in the concern Shared::IsData, if its available use it on the object
  def metamorphosize_if(object)
    if object.respond_to?(:metamorphosize) 
      object.metamorphosize
    else
      object
    end
  end

  # @return [String]
  #   the member path base for the object, object should be metamorphosized before passing.
  def member_base_path(object)
    object.class.name.tableize.singularize
  end

  # @return [String]
  #   the member path base for the object, object should be metamorphosized before passing.
  def collection_base_path(object)
    object.class.name.tableize
  end

  # Given the object (non metamorphosized), return the helper instance
  def helper_module(object)
    (object.class.name + 'Helper').constantize
  end

end
