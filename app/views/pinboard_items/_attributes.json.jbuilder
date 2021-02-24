json.extract! pinboard_item, :id, :user_id, :pinned_object_type,
  :pinned_object_id, :position, :is_inserted, :is_cross_project,
  :inserted_count 

json.pinned_object_section pinboard_item.pinned_object.class.name.pluralize # Object.pinned_object_type.pluralize

if pinboard_item.pinned_object.kind_of?(Source)
  json.pinned_object_documents do
    json.array! pinboard_item.pinned_object.documents.each do |document|
      json.partial! '/documents/attributes', document: document
    end
  end
end

json.partial! '/shared/data/all/metadata', object: pinboard_item 

json.pinned_object do
  json.partial! '/shared/data/all/metadata', object: pinboard_item.pinned_object
end

