module TaxonName::MatrixHooks
  extend ActiveSupport::Concern

  # @return Scope
  def coordinate_observation_matrix_row_items
    ObservationMatrixRowItem::Dynamic::TaxonName #.joins(:taxon_name)
      .where( observation_object: self_and_ancestors )
  end

  def in_scope_observation_matrix_row_items
    return [] unless parent_id_changed?
    TaxonName.find(parent_id_change.last).coordinate_observation_matrix_row_items
  end

  def out_of_scope_observation_matrix_row_items
    return [] unless parent_id_changed? && parent_id_change.first
    TaxonName.find(parent_id_change.first).coordinate_observation_matrix_row_items   
  end

end
