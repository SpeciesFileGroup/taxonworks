json.extract! common_name, :id, :name, :geographic_area_id, :otu_id, :language_id, :start_year, :end_year, :created_at, :updated_at
json.partial! '/shared/data/all/metadata', object: common_name 

json.otu do
  json.partial! '/shared/data/all/metadata', object: common_name.otu
end

if otu.language.any?
  json.language do
    json.partial! '/shared/data/all/metadata', object: common_name.language
  end
end

if otu.geographic_area.any?
  json.language do
    json.partial! '/shared/data/all/metadata', object: common_name.geographic_area
  end
end
