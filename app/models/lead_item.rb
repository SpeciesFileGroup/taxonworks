# A LeadItem relates an otu to a lead for the purpose of tracking which otus
# from an initial set of otus for a key are still under consideration at a
# particular stage of the key.
#
# @!attribute lead_id
#   @return [integer]
#   id of the lead to which otu_id is attached
#
# @!attribute otu_id
#   @return [integer]
#   id of an otu which should be associated with lead_id
#
# @!attribute project_id
#   @return [Integer]
#   the project ID
#
class LeadItem < ApplicationRecord
  include Housekeeping
  include Shared::IsData

  acts_as_list scope: [:lead_id, :project_id]

  belongs_to :otu, inverse_of: :lead_items
  belongs_to :lead, inverse_of: :lead_items

  has_one :taxon_name, through: :otu

  validates_presence_of :otu, :lead

  def self.batch_populate(lead_id, otus)
    otus.each do |o|
      LeadItem.find_or_create_by!(lead_id:, otu: o)
    end
  end

  def self.exists_on_lead_set(otu_id, lead_ids)
    where(otu_id:, lead_id: lead_ids).exists?
  end
end
