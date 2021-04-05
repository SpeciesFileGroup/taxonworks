json.extract! extract, :id, 
:extract_object_id, :extract_object_type,
:verbatim_anatomical_origin,
:year_made, :month_made, :day_made,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: :extract

json.extract_object do
  json.partial! '/shared/data/all/metadata', object: :extact_object
end
