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
#   Stubbed placeholder for Revision (sensus taxonomy) model.  NOT PRESENTLY USED.
#
class Content < ApplicationRecord
  include Housekeeping
  include Shared::Depictions
  include Shared::Confidences
  include Shared::Citations
  include Shared::Attributions
  include Shared::IsData
  include Shared::HasPapertrail
  include Shared::DataAttributes
  ignore_whitespace_on(:text)

  belongs_to :otu, inverse_of: :contents
  belongs_to :topic, inverse_of: :contents
  has_one :public_content
  belongs_to :language

  validates_uniqueness_of :topic, scope: [:otu]

  validates_presence_of :text
  validates :topic, presence: true
  validates :otu, presence: true

  # scope :for_otu_page_layout, -> (otu_page_layout_id) {
  #   where('otu_page_layout_id = ?', otu_page_layout.od)
  # }

  # @return [Boolean]
  #    true if this content has been published
  def published?
    self.public_content
  end

  # TODO: this will have to be updated in subclasses.
  def publish
    to_publish = {
      topic: self.topic,
      text:  self.text,
      otu:   self.otu
    }

    self.public_content.delete if self.public_content
    self.public_content = PublicContent.new(to_publish)
    self.save
  end

  def unpublish
    self.public_content.destroy
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
end
