# A snapshot of the working content that is OK for public consumption. 
#
# * This needs work to resolve b/w OTU and other content.
#
# @!attribute otu_id
#   @return [Integer]
#     they Otu 
#
# @!attribute topic_id
#   @return [Integer]
#     the topic
#
# @!attribute text
#   @return [String]
#      the meat 
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute content_id
#   @return [Integer]
#     pointer to the working version 
#
class PublicContent < ApplicationRecord
  include Housekeeping

  belongs_to :otu, inverse_of: :public_contents
  belongs_to :topic
  belongs_to :content, inverse_of: :public_content

  validates_presence_of :text, :topic_id # is general, or always OTU?

  def version
    self.content.version
  end

end
