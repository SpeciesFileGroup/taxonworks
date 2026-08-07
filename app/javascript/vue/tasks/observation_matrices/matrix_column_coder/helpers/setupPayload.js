export function setupFreeTextPayload (observation) {
  return { description: observation.description }
}

export function setupQualitativePayload (args) {
  return { character_state_id: args.characterStateId }
}

export function setupPresencePayload (observation) {
  return { presence: observation.isChecked }
}

export function setupContinuosPayload (observation) {
  return {
    continuous_value: observation.continuousValue,
    continuous_unit: observation.continuousUnit
  }
}

export function setupSamplePayload (observation) {
  return {
    sample_n: observation.n,
    sample_min: observation.min,
    sample_max: observation.max,
    sample_median: observation.median,
    sample_mean: observation.mean,
    sample_units: observation.units,
    sample_standard_deviation: observation.standardDeviation,
    sample_standard_error: observation.standardError
  }
}
