module Shared::Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tags, as: :tag_object, validate: false
    has_many :keywords, through: :tags 

    scope :with_tags, -> { joins(:tags) }
    scope :without_tags, -> { includes(:tags).where(tags: {id: nil}) }
  end 

  def tagged?
    self.tags.count > 0
  end

end
