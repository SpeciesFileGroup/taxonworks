export function customReplace(match, text) {
  return match.reduce(
    (acc, curr, index) =>
      acc.replace(new RegExp('\\$' + (index + 1), 'g'), curr),
    text
  )
}
