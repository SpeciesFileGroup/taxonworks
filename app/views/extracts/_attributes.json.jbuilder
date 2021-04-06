json.extract! extract, :id, 
:verbatim_anatomical_origin,
:repository_id,
:year_made, :month_made, :day_made,
:created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: extract
