# PublicContent definition...
# @todo
#
# * This needs work to resolve b/w OTU and other content.
#
# @!attribute otu_id
#   @return [Integer]
#   @todo
#
# @!attribute topic_id
#   @return [Integer]
#   @todo
#
# @!attribute text
#   @return [String]
#   @todo
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
# @!attribute content_id
#   @return [Integer]
#   @todo
#
class PublicContent < ApplicationRecord
  include Housekeeping

  belongs_to :otu
  belongs_to :topic
  belongs_to :content

  validates_presence_of :text
  validates :topic, presence: true

  def version
    self.content.version
  end

end
