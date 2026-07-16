export const MAX_ROWS = 3000

// A fresh array/objects each call, so callers never share mutable state.
export function defaultModifiers() {
  return [
    { active: false, pattern: '^(\\S*\\s+\\S*).*', replacement: '$1' },
    { active: false, pattern: '', replacement: '' }
  ]
}
