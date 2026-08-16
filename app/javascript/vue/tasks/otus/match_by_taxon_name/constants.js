export const MAX_ROWS = 3000

export const TAXON_NAME_FILTER = {
  All: 'all',
  Ambiguous: 'ambiguous',
  Unmatched: 'unmatched'
}

// A fresh array/objects each call, so callers never share mutable state.
export function defaultModifiers() {
  return [
    { active: false, pattern: '^(\\S*\\s+\\S*).*', replacement: '$1' },
    { active: false, pattern: '', replacement: '' }
  ]
}
