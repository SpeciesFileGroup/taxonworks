export default (originRelationship) => ({
  id: originRelationship.id,
  old_object_type: originRelationship.old_object_type,
  old_object_id: originRelationship.old_object_id,
  label: originRelationship.old_object_object_tag
})
