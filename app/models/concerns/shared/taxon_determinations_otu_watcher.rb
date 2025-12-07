# Detects when a TaxonDetermination change alters the parent object's accepted
# OTU, and alerts the taxon_determination_object.
module Shared::TaxonDeterminationsOtuWatcher
  extend ActiveSupport::Concern

  included do
    attr_accessor :_prev_top_otu_id

    before_create  :capture_previous_top_otu_id
    before_update  :capture_previous_top_otu_id
    before_destroy :capture_previous_top_otu_id

    after_commit :propagate_if_top_otu_changed, on: [:create, :update, :destroy]
  end

  private

  def capture_previous_top_otu_id
    obj = taxon_determination_object
    self._prev_top_otu_id = obj.respond_to?(:current_otu) ? obj.current_otu&.id : nil
    true
  end

  def propagate_if_top_otu_changed
    obj = taxon_determination_object
    return true unless obj && obj.respond_to?(:propagate_current_otu_change!)

    new_id = obj.respond_to?(:current_otu) ? obj.current_otu&.id : nil
    old_id = _prev_top_otu_id
    return true if old_id == new_id

    obj.propagate_current_otu_change!(from_id: old_id, to_id: new_id)
    true
  rescue => e
    Rails.logger.warn("OtuWatcher for TaxonDetermination##{id} failed: #{e.class}: #{e.message}")
    false
  end
end
