const ROW_SEPARATOR = /\r?\n/
const CELL_SEPARATOR = /\t/

function parseClipboardTable(text) {
  if (typeof text !== 'string' || !text.length) {
    return []
  }

  return text
    .replace(/\r?\n$/, '')
    .split(ROW_SEPARATOR)
    .map((row) => row.split(CELL_SEPARATOR))
}

export { parseClipboardTable }
