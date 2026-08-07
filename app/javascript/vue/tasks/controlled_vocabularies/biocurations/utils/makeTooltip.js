export default item => {
  return `
  ${item.definition}

${item.uri || ''}
`.trim()
}
