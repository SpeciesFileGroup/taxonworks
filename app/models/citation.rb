# Citation is like Roles in that it is also a linking table between a data object & a source.
# (Assertion that the subject was referenced in a source)
class Citation < ActiveRecord::Base
  include Housekeeping

  belongs_to :citation_object, polymorphic: :true

  belongs_to :source, inverse_of: :citations

  has_many :citation_topics, inverse_of: :citation

  validates_presence_of :citation_object_id, :citation_object_type, :source_id
  validates_uniqueness_of :citation_object_id, :citation_object_type, :source_id
end
