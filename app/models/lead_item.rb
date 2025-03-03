class LeadItem < ApplicationRecord
  include Housekeeping

  acts_as_list scope: [:lead_id, :project_id]

  belongs_to :otu, inverse_of: :lead_items
  belongs_to :lead, inverse_of: :lead_items
  belongs_to :project

  has_one :taxon_name, through: :otu

  validates_presence_of :otu, :lead

  def self.batch_populate(lead_id, otus)
    otus.each do |o|
      # TODO check result
      LeadItem.find_or_create_by!(lead_id:, otu: o)
    end
  end

  def self.exists_on_lead_set(otu_id, lead_ids)
    where(otu_id:, lead_id: lead_ids).count > 0
  end
end
