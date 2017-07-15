module Tasks::Gis::MatchGeoreferenceHelper
  def collecting_events_count_using_this_geographic_item(gr)
    Georeference.where(geographic_item_id: gr).with_project_id(sessions_current_project_id).pluck(:collecting_event_id).count
  end

  def collecting_events_count_using_this_error_geographic_item(gr)
    gr.blank? ? 0 : Georeference.where(error_geographic_item_id: gr).with_project_id(sessions_current_project_id).pluck(:collecting_event_id).count
  end
end
