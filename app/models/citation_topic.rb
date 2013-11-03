class CitationTopic < ActiveRecord::Base
  belongs_to :topic
  belongs_to :citation

  validates_presence_of :topic_id, :citation_id
  validates_uniqueness_of :topic_id, :citation_id

  before_save :trim_pages

  protected

  def trim_pages # pages should have content or be empty
    self.pages = self.pages.to_str.strip
  end
end
