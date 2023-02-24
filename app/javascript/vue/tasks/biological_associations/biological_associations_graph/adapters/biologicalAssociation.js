export function makeBiologicalAssociation(ba) {
  return {
    uuid: crypto.randomUUID(),
    ba: ba.id,
    name: ba.name,
    biologicalRelationship: {
      ...ba.biological_relationship,
      id: ba.biological_relationship_id,
      name: ba.biological_relationship.object_label
    },
    subject: ba.subject,
    object: ba.object
  }
}
