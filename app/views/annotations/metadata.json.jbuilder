json.annotation_target @object.to_global_id.to_s
json.url url_for(@object.metamorphosize)
json.object_type @object.class.base_class.name
json.object_id @object.id
json.annotation_types @object.annotation_metadata

  
