class CitationTopic < ActiveRecord::Base
  belongs_to :topic
  belongs_to :citation
end
