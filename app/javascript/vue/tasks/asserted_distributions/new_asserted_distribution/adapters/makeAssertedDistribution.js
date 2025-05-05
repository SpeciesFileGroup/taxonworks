export function makeAssertedDistribution(data = {}) {
  return {
    id: data.id,
    isAbsent: data.is_absent,
    isUnsaved: false
  }
}
