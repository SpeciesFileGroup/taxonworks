
# to adding attributes to CSS.  Also includes 'data-' related functionality.
# general helpers that work on objects
module Workbench::ObjectHelper

  def metamorphosize_if(object)
    if object.respond_to?(:metamorphosize) 
      object.metamorphosize
    else
      object
    end
  end


end
