module Shared::Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tags, as: :tag_object
  end 

  def tagged?
    self.tags.count > 0
  end

end
