# Content is text related blocks, at present it only pertains to Otus.
# It requires both a Topic and an Otu.
# Future extensions may be added to use the model for Projects, etc. via STI.
#
# @!attribute text
#   @return [String]
#   The written content.
#
# @!attribute otu_id
#   @return [Integer]
#   When OtuContent::Text the id of the Otu the content pertains to.  At present required.
#
# @!attribute topic_id
#   @return [Integer]
#   When OtuContent::Text the id of the Topic the content pertains to. At present required.
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute revision_id
#   @return [Integer]
#   Stubbed placeholder for Revision (sensus taxonomy) model. NOT PRESENTLY USED.
#
class Content < ApplicationRecord
  include Housekeeping
  include Shared::Depictions
  include Shared::Confidences
  include Shared::Citations
  include Shared::Attributions
  include Shared::HasPapertrail
  include Shared::DataAttributes # TODO: reconsider, why is this here?  Should be removed, use case is currently cross reference to an identifier, if required use Identifier
  include Shared::IsData
  ignore_whitespace_on(:text)

  attr_accessor :is_public 

  after_save :publish, if: -> { (is_public == true) || is_public == '1' }
  after_save :unpublish, if: -> { (is_public == false) || (is_public == '0') }

  belongs_to :otu, inverse_of: :contents
  belongs_to :topic, inverse_of: :contents
  has_one :public_content, inverse_of: :content
  belongs_to :language

  validate :topic_id_is_type_topic

  validates_uniqueness_of :topic_id, scope: [:otu_id]
  validates_presence_of :text, :topic_id, :otu_id

  # scope :for_otu_page_layout, -> (otu_page_layout_id) {
  #   where('otu_page_layout_id = ?', otu_page_layout.od)
  # }

  # @return [Boolean]
  #    true if this content has been published
  def is_published?
    public_content.present?
  end

  # TODO: this will have to be updated in subclasses.
  def publish
    public_content.delete if public_content
    PublicContent.create!(
      content: self,
      topic: topic,
      text:  text,
      otu:   otu
    )
  end

  def unpublish
    public_content.destroy
  end

  # OTU_PAGE_LAYOUTS
  #       V
  # OTU_PAGE_LAYOUT_SECTIONS ^ .otu_page_layout_id v .topic_id
  #       V
  #     TOPICS
  #       V
  #    CONTENTS              v otu_id              ^ .topic_id
  #       ^
  #      OTU
  #
  # Given an otu_page_layout id. find all the topics
  # For this otu_page_layout, find the topics (ControlledVocabularyTerm.of_type(:topic))

  def self.for_page_layout(otu_page_layout_id)
    where('topic_id in (?)', OtuPageLayout.where(id: otu_page_layout_id).first.topics.pluck(:id))
  end

  def self.find_for_autocomplete(params)
    where('text ILIKE ? OR text ILIKE ?', "#{params[:term]}%", "%#{params[:term]}%")
  end

  def self.used_recently(user_id, project_id)
    Content.touched_by(user_id).where(project_id: project_id).order(updated_at: :desc).limit(6).to_a
  end

  def self.select_optimized(user_id, project_id)
    r = used_recently(user_id, project_id)

    h = {
      quick: Content.pinned_by(user_id).pinboard_inserted.where(project_id: project_id).to_a,
      pinboard: Content.pinned_by(user_id).where(project_id: project_id).to_a,
      recent: used_recently(user_id, project_id)
    }

    h
  end

  private

  def topic_id_is_type_topic
    if topic_id
      errors.add(:topic_id, 'is not a Topic id') if !Topic.find(topic_id)
    end
  end
end
