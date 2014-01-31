class Content < ActiveRecord::Base
  include Housekeeping

  belongs_to :otu
  belongs_to :topic, inverse_of: :contents

  validates_presence_of :text
  validates :otu, presence: true
  validates :topic, presence: true

end
