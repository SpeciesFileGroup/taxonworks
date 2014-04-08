module Shared::Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tags, as: :tag_object, validate: false
    has_many :keywords, through: :tags 
  end 

  def tagged?
    self.tags.count > 0
  end

end
