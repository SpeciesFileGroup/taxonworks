# A Protocol is a recipe for how something is done.
#
# Protocols are simple records, they can be Document(ed) with
#  external files (pdfs, text files, etc.)
#
class Protocol < ApplicationRecord
  include Housekeeping
  include Shared::IsData
#  include Shared::Documentable

  has_many :protocol_relationships, inverse_of: :protocol

  validates_presence_of :name
  validates_uniqueness_of :name, case_sensitive: false
  validates_presence_of :short_name
  validates_presence_of :description
end
