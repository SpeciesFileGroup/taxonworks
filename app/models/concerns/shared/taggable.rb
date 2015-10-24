# Shared code for...
#
module Shared::Taggable

  extend ActiveSupport::Concern

  included do
    has_many :tags, as: :tag_object, validate: true, dependent: :destroy
    has_many :keywords, through: :tags

    scope :with_tags, -> { joins(:tags) }
    scope :without_tags, -> { includes(:tags).where(tags: {id: nil}) }

    accepts_nested_attributes_for :tags, reject_if: :reject_tags, allow_destroy: true
  end

  def has_tags?
    self.tags.any?
  end

  module ClassMethods
    def tagged_with_keyword(keyword)
      joins(:tags).where(tags: {keyword: keyword})
    end
  end

  
  protected 

  def reject_tags(attributed)
    attributed['keyword_id'].blank?
  end

end
