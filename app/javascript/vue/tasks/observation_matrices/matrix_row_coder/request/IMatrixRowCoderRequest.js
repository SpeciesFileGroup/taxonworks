const IllegalBaseClassCallError = `Illegal call to base class IMatrixRowCoderRequest`

export default class IMatrixRowCoderRequest {
  getMatrixRow () {
    throw IllegalBaseClassCallError
  }

  getObservations () {
    throw IllegalBaseClassCallError
  }

  updateObservation () {
    throw IllegalBaseClassCallError
  }

  createObservation () {
    throw IllegalBaseClassCallError
  }

  createClone () {
    throw IllegalBaseClassCallError
  }

  removeObservation () {
    throw IllegalBaseClassCallError
  }

  removeAllObservationsRow () {
    throw IllegalBaseClassCallError
  }

  getDescriptorDepictions () {
    throw IllegalBaseClassCallError
  }

  getObservationDepictions () {
    throw IllegalBaseClassCallError
  }

  getUnits () {
    throw IllegalBaseClassCallError
  }

  getDescription () {
    throw IllegalBaseClassCallError
  }
}
