# A Citation is an assertion that the subject (i.e. citation object/record/data instance), or some attribute of it, was referenced or originate in a Source.
#
# @!attribute citation_object_type
#   @return [String]
#     Rails STI, the class of the object being cited
#
# @!attribute source_id
#   @return [Integer]
#   the source ID
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute citation_object_id
#   @return [Integer]
#    Rails STI, the id of the object being cited
#
# @!attribute pages
#   @return [String]
#     a specific location/localization for the data in the Source
#
class Citation < ApplicationRecord
  include Housekeeping
  include Shared::Notable
  include Shared::Confidence
  include Shared::DataAttributes
  include Shared::Taggable
  include Shared::IsData
  include Shared::PolymorphicAnnotator
  polymorphic_annotates('citation_object')

  belongs_to :source, inverse_of: :citations

  has_many :citation_topics, inverse_of: :citation, dependent: :destroy
  has_many :topics, through: :citation_topics

  validates_presence_of  :source_id
  validates_uniqueness_of :source_id, scope: [:citation_object_type, :citation_object_id, :pages]

  accepts_nested_attributes_for :citation_topics, allow_destroy: true, reject_if: :reject_citation_topics
  accepts_nested_attributes_for :topics, allow_destroy: true, reject_if: :reject_topic

  before_destroy :prevent_if_required

  after_create :add_source_to_project

  def prevent_if_required
    if !marked_for_destruction? && !new_record? && citation_object.requires_citation? && citation_object.citations.reload.count == 1
      errors.add(:base, 'at least one citation is required')
      # return false
      throw :abort
    end
  end

  after_save :update_related_cached_values, if: :is_original?

  # @return [Scope of matching sources]
  def self.find_for_autocomplete(params)
    term    = params['term']
    ending  = term + '%'
    wrapped = '%' + term + '%'
    joins(:source).where('sources.cached ILIKE ? OR sources.cached ILIKE ? OR citation_object_type LIKE ?', ending, wrapped, ending).with_project_id(params[:project_id])
  end

  # @return [Boolean]
  #   true if is_original is checked, false if nil/false
  def is_original?
    is_original ? true : false
  end

  protected

  def add_source_to_project
    if !ProjectSource.where(source: source).any?
      ProjectSource.create(project: project, source: source)
    end
    true
  end

  def reject_citation_topics(attributed)
    attributes['id'].blank? && attributed['topic_id'].blank? && attributed['topic'].blank? && attributed['topic_attributes'].blank?
  end

  def reject_topic(attributed)
    attributed['name'].blank? || attributed['definition'].blank?
  end

  def update_related_cached_values
    if citation_object_type == 'TaxonName'
      citation_object.update_attribute(:cached_author_year, citation_object.get_author_and_year)
    end
    true
  end

end
