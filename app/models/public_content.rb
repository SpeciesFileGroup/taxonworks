class PublicContent < ActiveRecord::Base
  include Housekeeping

  belongs_to :otu
  belongs_to :topic
  belongs_to :content

  validates_presence_of :text
  validates :otu, presence: true
  validates :topic, presence: true

  def version
    self.content.version
  end

end
