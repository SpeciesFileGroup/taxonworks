export function makeGraph(data) {
  return {
    id: data.id,
    uuid: crypto.randomUUID(),
    globalId: data.global_id,
    biologicalAssociationIds:
      data.biological_associations_biological_associations_graphs,
    layout: data.layout
  }
}
