module Shared::Taggable
  extend ActiveSupport::Concern

  included do
    has_many :tags, as: :tag_object, validate: false
    has_many :keywords, through: :tags 

    scope :with_tags, -> { joins(:tags) }
    scope :without_tags, -> { includes(:tags).where(tags: {id: nil}) }
  end 

  def has_tags?
    self.tags.any?
  end

  module ClassMethods
    def tagged_with_keyword(keyword)
      joins(:tags).where(tags: {keyword: keyword})
    end
  end

end
