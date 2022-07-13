json.extract! taxon_name_classification, :id, :taxon_name_id, :type, :created_by_id, :updated_by_id, :project_id, :created_at, :updated_at

json.object_tag taxon_name_classification_tag(taxon_name_classification)
json.url taxon_name_classification_url(taxon_name_classification, format: :json)
json.global_id taxon_name_classification.to_global_id.to_s

json.partial! '/shared/data/all/metadata', object: taxon_name_classification
