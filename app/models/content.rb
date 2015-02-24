
# Content is text related blocks.  At present there is
# only one subclass, OtuContent, that requires both a Topic and an Otu.
# Future extensions may be added to use the model for Projects etc.
#
# @!attribute text
#   @return [Text] The written content. 
# @!attribute otu_id 
#   @return [Integer] When OtuContent::Text the id of the Otu the content pertains to.  At present required.
# @!attribute topic_id 
#   @return [Integer] When OtuContent::Text the id of the Topic the content pertains to. At present required.
# @!attribute type 
#   @return [string]  The content subclass.  Only one is supported at present OtuContent::Text.
# @!attribute revision_id 
#   @return [integer] Stubbed placeholder for Revision (sensus taxonomy) model.  NOT PRESENTLY USED. 
#
class Content < ActiveRecord::Base
  include Housekeeping
  include Shared::IsData

  has_paper_trail 

  belongs_to :topic, inverse_of: :contents
  has_one :public_content

  validates_presence_of :text
  validates :topic, presence: true

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
    }

    self.public_content.delete if self.public_content
    self.public_content = PublicContent.new(to_publish)
    self.save
  end

  def unpublish
    self.public_content.destroy
  end

  def self.find_for_autocomplete(params)
    where('text ILIKE ? OR text ILIKE ?', "#{params[:term]}%", "%#{params[:term]}%")
  end

end
