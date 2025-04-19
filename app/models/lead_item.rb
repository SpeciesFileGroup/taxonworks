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

  def self.batch_add_otus_for_lead(lead_id, otu_ids, project_id, user_id)
    attributes = otu_ids.map { |otu_id|
      {
        otu_id:,
        lead_id:,
        project_id:,
        created_by_id: user_id,
        updated_by_id: user_id
      }
    }

    LeadItem.insert_all(attributes)
  end

  def self.move_items(items_scope, lead)
    items_scope.update_all(lead_id: lead.id)
  end

  # Transfers any items on leaf-node descendants of source to a new lead.
  # @param target [Lead or nil] A lead to add the descendant lead_items to; if
  #   nil a new lead is created.
  # @return [Lead or nil] If items exist, the lead now holding those items.
  def self.consolidate_descendant_items(lead, target = nil)
    # Both lead and lead_item have `position`, which .leaves orders by, so need
    # to remove that.
    items =
      lead.leaves.unscope(:order).joins(:lead_items).pluck('lead_items.id')

    return nil if items.empty?

    items_lead = target || Lead.create!(text:
      'PLACEHOLDER LEAD TO HOLD OTU OPTIONS FROM A DELETED SUBTREE'
    )

    self.move_items(LeadItem.where(id: items), items_lead)

    items_lead
  end

  def self.add_otu_index_for_lead(lead, otu_id)
    begin
      Lead.transaction do
        LeadItem.where(lead_id: lead.sibling_ids, otu_id:).destroy_all

        LeadItem.create!(lead_id: lead.id, otu_id:)
      end
    rescue ActiveRecord::RecordNotDestroyed => e
      lead.errors.add(:base, "Destroy sibling LeadItems failed! '#{e}'")
      return false
    rescue ActiveRecord::RecordInvalid => e
      lead.errors.add(:base, "New LeadItem creation failed! '#{e}'")
      return false
    end

    true
  end

end
