
# This needs work to resolve b/w OTU and other content.
class PublicContent < ActiveRecord::Base
  include Housekeeping

  belongs_to :otu
  belongs_to :topic
  belongs_to :content

  # Validation follows Content (not OtuContent) for now.
  validates_presence_of :text
  validates :topic, presence: true

  def version
    self.content.version
  end

end
