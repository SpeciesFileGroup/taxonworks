class ObservationMatrixRowItem::Dynamic < ObservationMatrixRowItem
  validates_absence_of :observation_object_id, :observation_object_type

  def is_dynamic?
    true
  end
end
