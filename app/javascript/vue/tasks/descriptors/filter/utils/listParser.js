export function listParser(list) {
  return list.map((item) => ({
    ...item,
    character_states: `<ul>${(item.character_states || [])
      .map((c) => `<li>${c.name}</li>`)
      .join('')}</ul>`
  }))
}
