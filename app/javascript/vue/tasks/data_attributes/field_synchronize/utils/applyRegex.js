export function applyRegex(text, regexPatterns) {
  try {
    for (let i = 0; i < regexPatterns.length; i++) {
      const pattern = regexPatterns[i]
      const regex = new RegExp(pattern.match, 'g')

      if (pattern.match) {
        if (pattern.replace) {
          text = text?.replace(regex, pattern.value)
        } else {
          const found = text.match(regex)

          if (found) {
            text = found[0]
          } else {
            return text
          }
        }
      }
    }
  } catch {
    /* empty */
  }

  return text
}
