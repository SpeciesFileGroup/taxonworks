import { PATTERN_TYPES } from '../constants'
import { customReplace } from './customReplace'

export function applyRegex(text, regexPatterns) {
  try {
    for (let i = 0; i < regexPatterns.length; i++) {
      const pattern = regexPatterns[i]
      const regex = new RegExp(pattern.match, 'g')

      if (pattern.match) {
        if (pattern.mode === PATTERN_TYPES.Replace) {
          text = text?.replace(regex, pattern.value)
        } else if (pattern.mode === PATTERN_TYPES.Match) {
          const found = text?.match(regex)

          if (found) {
            text = found[0]
          } else {
            break
          }
        }
      }
    }
  } catch {
    /* empty */
  }

  return text
}

export function applyExtract(pattern, from, to) {
  try {
    const regex = new RegExp(pattern.match, 'g')
    const matchedGroups = from?.match(regex)
    const toValue = to != null ? to : ''

    if (matchedGroups) {
      from = from?.replace(regex, '')
      to = toValue + customReplace(matchedGroups, pattern.value)
    }
  } catch {
    /* empty */
  }

  return {
    from,
    to
  }
}
