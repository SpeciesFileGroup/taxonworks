function randomHue (index = Math.random() * 512) {
  const PHI = (1 + Math.sqrt(5)) / 2
  const n = index * PHI - Math.floor(index * PHI)
  return `hsl(${Math.floor(n * 256)}, ${Math.floor(n * 50) + 100}% , ${(Math.floor((n) + 1) * 60) + 10}%)`
}

export {
  randomHue
}
