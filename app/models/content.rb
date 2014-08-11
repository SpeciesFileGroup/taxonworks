class Content < ActiveRecord::Base
  include Housekeeping
  has_paper_trail

  belongs_to :otu, inverse_of: :contents
  belongs_to :topic, inverse_of: :contents
  has_one :public_content

  validates_presence_of :text
  validates :otu, presence: true
  validates :topic, presence: true

  def published?
    self.public_content
  end

  def publish
    to_publish = {
      otu:   self.otu,
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
    where('name LIKE ?', "#{params[:term]}%")
  end

end
