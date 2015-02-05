# All models that are referenced across projects include this code
#
module Shared::Annotates
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end

  def annotates_community?
    self.annotated_object.class <= Shared::SharedAcrossProjects
  end

end
