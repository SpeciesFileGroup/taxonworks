export default (originRelationship) => ({
  id: originRelationship.id,
  newObject: {
    ...originRelationship.new_object,
    new_object_type: originRelationship.new_object_type
  },
  oldObject: {
    ...originRelationship.old_object,
    old_object_type: originRelationship.old_object_type,
    old_object_id: originRelationship.old_object_id
  },
  object_tag: originRelationship.old_object_object_tag
})
