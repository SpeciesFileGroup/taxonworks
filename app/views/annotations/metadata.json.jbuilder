json.annotation_target @object.to_global_id.to_s
json.url url_for(@object.metamorphosize)
json.object_type @object.class.base_class.name
json.object_id @object.id
json.endpoints @object.annotation_metadata(sessions_current_project_id)
json.object_tag object_tag(@object)

json.partial! '/pinboard_items/pinned', object: @object
