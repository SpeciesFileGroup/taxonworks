export default function (observationData) {
  return {
    id: observationData.id || null,
    internalId: Math.random().toString(36).substr(2, 5),
    descriptorId: observationData.descriptorId || observationData.descriptor_id,
    rowObjectId: observationData.rowObjectId || observationData.observation_object_id,
    rowObjectType: observationData.rowObjectType || observationData.observation_object_type,
    type: observationData.type,
    global_id: observationData.global_id,
    depictions: [],
    isUnsaved: false,
    day: observationData.day_made,
    month: observationData.month_made,
    year: observationData.year_made,
    time: observationData.time_made
  }
}
