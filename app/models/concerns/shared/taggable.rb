# Shared code for extending data-classes with Tags.
#
module Shared::Taggable

  extend ActiveSupport::Concern

  included do
    has_many :tags, as: :tag_object, dependent: :destroy
    has_many :keywords, through: :tags

    scope :with_tags, -> { joins(:tags) }
    scope :without_tags, -> { includes(:tags).where(tags: {id: nil}) }

    accepts_nested_attributes_for :tags, reject_if: :reject_tags, allow_destroy: true

    validate :identical_new_keywords_are_prevented

    protected 
    
    def identical_new_keywords_are_prevented
      a = []
      tags.each do |t| 
        errors.add(:base, 'identical keyword attempt') if a.include?(t.keyword.attributes)
        a.push t.keyword.attributes
      end
    end
  end

  def tagged?
    self.tags.any?
  end

  module ClassMethods

    # @params [Keyword] the target keyword object
    # @return [Scope]
    #    only those instances with tags that use the kewyord
    def tagged_with_keyword(keyword)
      joins(:tags).where(tags: {keyword: keyword})
    end
  end

  protected 

  def reject_tags(attributed)
    (attributed['keyword'].blank? && attributed['keyword_id'].blank?) && 
      attributed['position'].blank? && 
      attributed['keyword_attributes'].blank?   
  end

end
