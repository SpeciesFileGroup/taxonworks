const IllegalBaseClassCallError = `Illegal call to base class IMatrixRowCoderRequest`;

export default class IMatrixRowCoderRequest {
    setApi() {
        throw IllegalBaseClassCallError;
    }

    getMatrixRow() {
        throw IllegalBaseClassCallError;
    }

    getObservations() {
        throw IllegalBaseClassCallError;
    }

    updateObservation() {
        throw IllegalBaseClassCallError;
    }

    createObservation() {
        throw IllegalBaseClassCallError;
    }

    removeObservation() {
        throw IllegalBaseClassCallError;
    }

    getDescriptorNotes() {
        throw IllegalBaseClassCallError;
    }

    getDescriptorDepictions() {
        throw IllegalBaseClassCallError;
    }

    getObservationNotes() {
        throw IllegalBaseClassCallError;
    }

    getObservationDepictions() {
        throw IllegalBaseClassCallError;
    }

    getObservationConfidences() {
        throw IllegalBaseClassCallError;
    }

    getObservationCitations() {
        throw IllegalBaseClassCallError;
    }

    getConfidenceLevels() {
        throw IllegalBaseClassCallError;
    }
}