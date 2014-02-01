class PublicContent < ActiveRecord::Base
  belongs_to :otu
  belongs_to :topic
  belongs_to :project
end
