export default function(observationData) {
    return {
        id: observationData.id || null,
        descriptorId: observationData.descriptorId || observationData.descriptor_id,
        type: observationData.type,
        notes: [],
        depictions: [],
        confidences: [],
        citations: [],
        isUnsaved: false
    };
};