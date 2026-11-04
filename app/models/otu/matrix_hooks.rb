module Otu::MatrixHooks

  extend ActiveSupport::Concern

  # These row items used to include this item as a member 
  def member_of_old_matrix_row_items
    return [] unless taxon_name_id_changed? && taxon_name_id_change.first
    TaxonName.find(taxon_name_id_change.compact.first).coordinate_observation_matrix_row_items
  end

  # These row items now include this item as a member 
  def member_of_new_matrix_row_items
    return [] unless taxon_name_id_change && taxon_name_id_change.last
    TaxonName.find(taxon_name_id_change.last).coordinate_observation_matrix_row_items
  end

  # Dynamic::TaxonName row items that include this item as a member through
  # its taxon_name_id (tag membership is released by Tag's own matrix hooks)
  def member_of_current_matrix_row_items
    return [] if taxon_name_id.nil?
    TaxonName.find_by(id: taxon_name_id)
      &.coordinate_observation_matrix_row_items || []
  end

end



