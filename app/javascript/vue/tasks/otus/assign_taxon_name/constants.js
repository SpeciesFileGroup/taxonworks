// Page size, and the server's per-request maximum.
export const PER = 500

// Mutually exclusive strip rules offered above the free-form modifiers. They are exclusive
// because `stripToFirstWord` subsumes the other two — stacked, the narrow rules could never
// be seen to do anything.
export const STRIP_PRESETS = [
  { value: null, label: 'None', pattern: null },
  // `sp` must be a whole token: the trailing (\s.*)?$ is what keeps this off `Aus spinosus`.
  { value: 'sp', label: 'Drop "sp." and anything after', pattern: '\\s+sp\\.?(\\s.*)?$' },
  { value: 'number', label: 'Drop a trailing number and anything after', pattern: '\\s+\\d+.*$' },
  { value: 'firstWord', label: 'Keep the first word only', pattern: '\\s+.*$' }
]

// A fresh array/objects each call, so callers never share mutable state.
export function defaultModifiers() {
  return [{ active: false, pattern: '', replacement: '' }]
}

export const VISIBILITY = {
  All: 'all',
  Set: 'set',
  Unset: 'unset'
}

// Rows are "predicted" when the matcher returned at least one candidate.
export const PREDICTION = {
  All: 'all',
  Predicted: 'predicted',
  Unknown: 'unknown'
}
