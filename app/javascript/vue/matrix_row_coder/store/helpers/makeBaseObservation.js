export default function (observationData) {
  console.log("Entra en Make")
  console.log(observationData)
  return {
    id: observationData.id || null,
    descriptorId: observationData.descriptorId || observationData.descriptor_id,
    type: observationData.type,
    global_id: observationData.global_id,
    notes: [],
    depictions: [],
    confidences: [],
    citations: [],
    isUnsaved: false
  }
};
