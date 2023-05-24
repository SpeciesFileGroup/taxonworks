class CachedMap < ApplicationRecord
  include Housekeeping::Projects
  include Housekeeping::Timestamps
  include Shared::IsData
  
  belongs_to :otu

  # All cached_map items used to compose this cached_map.
  def cached_map_items
    CachedMapItem.where(type: cached_map_type, otu: otu_scope)
  end

  validates_presence_of :otu
  validates_presence_of :geometry
  validates_presence_of :reference_count

  def synced?
    cached_map_items_reference_total == reference_count && latest_cached_map_item.created_at <= created_at 
  end

  def latest_cached_map_item 
    cached_map_items.order(:updated_at).first
  end

  def cached_map_items_reference_total
    CachedMapItem.where(otu: otu_scope).sum(:reference_count)
  end

  def otu_scope
    if otu.taxon_name
      Otu.descendant_of_taxon_name(otu.taxon_name_id)
    else
      Otu.coordinate_otus(otu.id)
    end
  end

end
