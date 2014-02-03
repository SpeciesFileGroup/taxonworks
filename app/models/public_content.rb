class PublicContent < ActiveRecord::Base
  include Housekeeping
  belongs_to :otu
  belongs_to :topic
  belongs_to :project

  before_save :increment_version

  validates_presence_of :text
  validates :otu, presence: true
  validates :topic, presence: true

  protected

  def increment_version
    self.version ||= 0
    self.version += 1
  end
end
