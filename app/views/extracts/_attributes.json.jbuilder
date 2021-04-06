json.extract! extract, :id, 
:origin_relationships,
:verbatim_anatomical_origin,
:year_made, :month_made, :day_made,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: extract
