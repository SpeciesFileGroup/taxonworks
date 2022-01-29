# Shared code for extending data classes with Tags.
#
module Shared::Tags

  extend ActiveSupport::Concern

  included do
    Tag.related_foreign_keys.push self.name.foreign_key

    has_many :tags, as: :tag_object, dependent: :destroy
    has_many :keywords, through: :tags

    scope :with_tags, -> { joins(:tags) }
    scope :without_tags, -> { includes(:tags).where(tags: {id: nil}) }

    accepts_nested_attributes_for :tags, reject_if: :reject_tags, allow_destroy: true

    # TODO: This should be a Tag validation!? (this is nested keywords)
    validate :identical_new_keywords_are_prevented

    protected

    def identical_new_keywords_are_prevented
      a = []
      tags.each do |t|
        errors.add(:base, 'identical keyword attempt') if a.include?(id: t.keyword.id, name: t.keyword.name, definition: t.keyword.definition)
        # t.keyword.attributes cannot be used, because the updated_at is truncated after save. The date is returned in different format.
        a.push(id: t.keyword.id, name: t.keyword.name, definition: t.keyword.definition)
      end
    end
  end

  # @return [Boolean]
  #   true if the object has tags
  def tagged?
    tags.any?
  end

  # @return [Boolean]
  #   true if the object has a tak with this keyword
  def tagged_with?(keyword_id)
    tags.where(keyword_id: keyword_id).any?
  end

  def tag_with(keyword_id)
    tags << Tag.new(keyword_id: keyword_id)
  end

  module ClassMethods

    def tagged_with_uri(uri)
      joins("JOIN tags t1 on t1.tag_object_type = '#{self.base_class.name}' AND t1.tag_object_id = #{self.base_class.name.tableize}.id JOIN controlled_vocabulary_terms k1 on k1.id = t1.keyword_id").where('k1.uri = ?', uri)
    end

    # @params [Keyword] the target keyword object
    # @return [Scope]
    #    only those instances with tags that use the kewyord
    def tagged_with_keyword(keyword)
      joins(:tags).where(tags: {keyword: keyword})
    end
  end

  private

  def reject_tags(attributed)
    (attributed['keyword'].blank? && attributed['keyword_id'].blank?) &&
      attributed['position'].blank? &&
      attributed['keyword_attributes'].blank?
  end

end
