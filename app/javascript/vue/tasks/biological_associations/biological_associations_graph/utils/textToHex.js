const getSHA256Hash = async (input) => {
  const textAsBuffer = new TextEncoder().encode(input)
  const hashBuffer = await crypto.subtle.digest('SHA-256', textAsBuffer)
  const hashArray = Array.from(new Uint8Array(hashBuffer))
  const hash = hashArray.map((item) => item.toString(16).padStart(2, '0')).join('')

  return hash
}

function colorFromHash(hash) {
  const j = hash.substring(0, 1)
  const substr = parseInt(j, 16)

  hash = hash + hash

  return '#' + hash.substring(substr, substr + 6)
}

export async function getHexColorFromString(text) {
  return colorFromHash(await getSHA256Hash(text))
}
