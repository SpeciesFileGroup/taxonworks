json.svg_map sqed_waxy_layout(@sqed_depictions)
json.svg_legend sqed_waxy_legend_tag
json.navigation do
  json.global do
    json.first_with_data SqedDepiction.where(project_id: sessions_current_project_id).with_collection_object_data.first&.id
    json.last_with_data SqedDepiction.with_collection_object_data.where(project_id: sessions_current_project_id).last&.id
    json.last_without_data SqedDepiction.where(project_id: sessions_current_project_id).without_collection_object_data.last&.id
    json.first_without_data SqedDepiction.where(project_id: sessions_current_project_id).without_collection_object_data.first&.id
    json.last_by_user SqedDepiction.joins(:collection_object).where(project_id: sessions_current_project_id, updated_by_id: sessions_current_user_id).with_collection_object_data.order('collection_objects.updated_at').first&.id
  end
  json.filtered do
    json.first_with_data @base_query.with_collection_object_data.first&.id
    json.last_with_data @base_query.with_collection_object_data.last&.id
    json.last_without_data @base_query.without_collection_object_data.last&.id
    json.first_without_data @base_query.without_collection_object_data.first&.id
    json.last_by_user @base_query.joins(:collection_object).where(updated_by_id: sessions_current_user_id).with_collection_object_data.order('collection_objects.updated_at').first&.id
  end
end


