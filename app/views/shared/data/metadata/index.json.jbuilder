json.klass @klass

if Project::MANIFEST.include?(@klass) || %w{Source}.include?(@klass)

  k = @klass.safe_constantize 

  q = k.all 
  q = k.where(project_id: sessions_current_project_id) if k.columns.include?(:project_id)

  json.created_this_week q.created_this_week.count
  json.updated_this_week q.updated_this_week.count
  json.created_by_user q.where(created_by_id: sessions_current_user_id).count
  json.created_by_others q.where.not(created_by_id: sessions_current_user_id).count

  # Others...

else
  json.error 'INVALID KLASS'
end
