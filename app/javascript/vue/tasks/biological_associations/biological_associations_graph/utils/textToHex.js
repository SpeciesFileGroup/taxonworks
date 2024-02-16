function generateHash(text) {
  let hash = 0
  if (text.length === 0) return hash

  for (let i = 0; i < text.length; i++) {
    const char = text.charCodeAt(i)

    hash = (hash << 5) - hash + char
    hash |= 0
  }

  return Math.abs(hash).toString(16)
}

function colorFromHash(hash) {
  const j = hash.substring(0, 1)
  const substr = parseInt(j, 16)

  hash = hash + hash

  return '#' + hash.substring(substr, substr + 6)
}

export async function getHexColorFromString(text) {
  return colorFromHash(generateHash(text))
}
