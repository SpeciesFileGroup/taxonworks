# All models that are referenced across projects include this code
#
module Shared::Annotates
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods

  # return [Boolean] 
  # see .annotates? in the is_data concern 
  def is_annotator? 
    true
  end 
  
  end

  def annotates_community?
    self.annotated_object.class <= Shared::SharedAcrossProjects ? true : false
  end

end
