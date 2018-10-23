json.extract! common_name, :id, :name, :geographic_area_id, :otu_id, :language_id, :start_year, :end_year, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: common_name 
