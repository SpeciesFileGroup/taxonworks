
# @!attribute  test_me
#   some indenteded text for test_me
# @!attribute other_test
#   some other test data
class TaxonDetermination < ActiveRecord::Base

  include Shared::HasRoles

  belongs_to :otu
  belongs_to :biological_collection_object

  has_one :determiner, as: :role_object

end
