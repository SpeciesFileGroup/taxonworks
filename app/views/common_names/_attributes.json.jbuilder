json.extract! common_name, :id, :name, :geographic_area_id, :otu_id, :language_id, :start_year, :end_year, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: common_name 

json.otu do
  json.partial! '/shared/data/all/metadata', object: common_name.otu
end

json.language_tag language_tag(common_name.language)

if common_name.geographic_area
  json.geographic_area do
    json.partial! '/shared/data/all/metadata', object: common_name.geographic_area
  end
end
