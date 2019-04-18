# Concern for models that annotate BOTH project and community data 
#
module Shared::DualAnnotator
  extend ActiveSupport::Concern

  included do
  end

  module ClassMethods
  end
  
  attr_accessor :is_community_annotation

  def is_community_annotation?
    (is_community_annotation == true) || is_community_annotation.to_s == 'true'
  end

end
