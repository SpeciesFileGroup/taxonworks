# Shared code for extending data classes with Tags.
#
module Shared::Taggable

  extend ActiveSupport::Concern

  included do
    Tag.related_foreign_keys.push self.name.foreign_key

    has_many :tags, as: :tag_object, dependent: :destroy
    has_many :keywords, through: :tags

    scope :with_tags, -> { joins(:tags) }
    scope :without_tags, -> { includes(:tags).where(tags: {id: nil}) }

    accepts_nested_attributes_for :tags, reject_if: :reject_tags, allow_destroy: true

    # TODO: This should be a Tag validation!?
    validate :identical_new_keywords_are_prevented

    protected 
    
    def identical_new_keywords_are_prevented
      a = []
      tags.each do |t| 
        errors.add(:base, 'identical keyword attempt') if a.include?({:id => t.keyword.id, :name => t.keyword.name, :definition => t.keyword.definition})
        # t.keyword.attributes cannot be used, because the updated_at is truncated after save. The date is returned in different format.
        a.push ({:id => t.keyword.id, :name => t.keyword.name, :definition => t.keyword.definition})
      end
    end
  end

  # @return [Boolean]
  #   true if the object has tags
  def tagged?
    tags.any?
  end

  def tag_with(keyword_id)
    tags << Tag.new(keyword_id: keyword_id)
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
