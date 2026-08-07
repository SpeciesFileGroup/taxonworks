json.extract! otu_relationship, :id, :subject_otu_id, :type, :object_otu_id, :project_id, :created_at, :updated_at

json.partial! '/shared/data/all/metadata', object: otu_relationship
