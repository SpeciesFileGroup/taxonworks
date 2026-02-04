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

  validates :otu, :lead, presence: true

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
  # Items with otu_ids already on target are deleted rather than moved.
  # @param target [Lead or nil] A lead to add the descendant lead_items to; if
  #   nil a new lead is created.
  # @return [Lead or nil] If items exist, the lead now holding those items.
  def self.consolidate_descendant_items(lead, target = nil)
    target_otu_ids = target ? target.lead_items.pluck(:otu_id) : []

    # Both lead and lead_item have `position`, which .leaves orders by, so need
    # to remove that.
    source_leaves_scope = lead.leaves.unscope(:order)
    source_leaves_scope = source_leaves_scope.where.not(id: target.id) if target

    source_items = LeadItem.where(lead_id: source_leaves_scope.select(:id))

    # Identify duplicates and items to move before modifying.
    duplicate_ids = target_otu_ids.any? ? source_items.where(otu_id: target_otu_ids).pluck(:id) : []
    items_to_move_ids = source_items.where.not(otu_id: target_otu_ids).pluck(:id)

    return nil if items_to_move_ids.empty? && duplicate_ids.empty?

    items_lead = target || Lead.create!(text:
      'PLACEHOLDER LEAD TO HOLD OTU OPTIONS FROM A DELETED SUBTREE'
    )

    LeadItem.transaction do
      LeadItem.where(id: duplicate_ids).delete_all if duplicate_ids.any?
      move_items(LeadItem.where(id: items_to_move_ids), items_lead) if items_to_move_ids.any?
    end

    items_lead
  end

  def self.add_otu_index_for_lead(lead, otu_id, exclusive)
    begin
      Lead.transaction do
        if exclusive
          LeadItem.where(lead_id: lead.sibling_ids, otu_id:).destroy_all
        end

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

  def self.remove_otu_index_for_lead(lead, otu_id)
    count = LeadItem
      .where(otu_id:, lead_id: lead.self_and_siblings.map(&:id)).count

    if count == 1
      lead.errors.add(:base, "Can't destroy last lead item for otu #{otu_id}!")
      return false
    end

    begin
      LeadItem.where(lead_id: lead.id, otu_id:).destroy_all
    rescue ActiveRecord::RecordNotDestroyed => e
      lead.errors.add(:base, "Destroy LeadItem for lead #{lead.id}, otu #{otu_id} failed! '#{e}'")
      return false
    end

    true
  end

  # @param parent [Lead] With add_new_to_first_child, determines which lead to add
  #   items to
  # @param otu_ids [Array] Which otus to add
  # @param exclusive_otu_ids [Array] Remove these otus from all siblings of the
  #   lead added to
  # @param add_new_to_first_child [Boolean] if true then add lead otus *that
  #   already exist on parent* to parent's first child, otherwise (default) add
  #   all supplied otus to the last available (rightmost) child.
  def self.add_items_to_lead(parent, otu_ids, exclusive_otu_ids, add_new_to_first_child = false)
    if otu_ids.nil? || otu_ids.empty?
      parent.errors.add(:base, 'No otus to add!')
      return false
    elsif parent.children.empty?
      parent.errors.add(:base, 'No lead children to add to!')
      return false
    end

    lead_to_add_to = nil
    if add_new_to_first_child
      lead_to_add_to = parent.children.first
    else
      parent.children.to_a.reverse.each do |c|
        if c.children.exists?
          next
        else
          # We add to the rightmost available child.
          lead_to_add_to ||= c
        end
      end
    end

    if lead_to_add_to.nil?
      parent.errors.add(:base, 'No available lead to add otus to!')
      return false
    end

    # TODO: this is really special-case code for adding items from a matrix,
    # clean things up.
    if add_new_to_first_child
      # Limit to lead items that exist on the right lead.
      otu_ids = otu_ids & parent.children[1].lead_items.pluck(:otu_id)
    end
    existing = lead_to_add_to.lead_items.pluck(:otu_id)
    new_otu_ids = otu_ids - existing
    lead_item_table = LeadItem.arel_table

    LeadItem.transaction do
      begin
        to_be_destroyed = otu_ids.filter_map do |otu_id|
          exclusive_otu_ids.include?(otu_id) ? otu_id : false
        end
        if to_be_destroyed.count > 0
          LeadItem
            .where(lead_id: lead_to_add_to.sibling_ids)
            .where(otu_id: to_be_destroyed)
            .destroy_all
        end

        a = new_otu_ids.map { |id| { lead_id: lead_to_add_to.id, otu_id: id } }
        LeadItem.create!(a)
        return {
          lead_id: lead_to_add_to.id,
          added_count: new_otu_ids.length,
          exclusive_added_count: (new_otu_ids & exclusive_otu_ids).length
        }
      rescue ActiveRecord::RecordNotDestroyed => e
        lead.errors.add(:base, e.to_s)
        byebug
        return false
      rescue ActiveRecord::RecordInvalid => e
        lead.errors.add(:base, e.to_s)
        byebug
        return false
      end
    end

    {
      lead_id: lead_to_add_to.id,
      added_count: new_otu_ids.length,
      exclusive_added_count: (new_otu_ids & exclusive_otu_ids).length
    }
  end

end
