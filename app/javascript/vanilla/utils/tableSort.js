const ASCENDING = 'ascending'
const DESCENDING = 'descending'

const directionCountByHeader = new WeakMap()
const parsersByTable = new WeakMap()

function parseNumber(value) {
  const number = parseFloat(value.replace(/,/g, ''))

  return isNaN(number) ? 0 : number
}

function parseDate(value) {
  const time = new Date(value).getTime()

  return isNaN(time) ? 0 : time
}

const textParser = {
  type: 'text',
  format: (value) => value.trim().toLocaleLowerCase()
}

const numericParsers = [
  {
    test: (value) => /^[-+]?\d*$/.test(value.replace(/[,.']/g, '').trim()),
    format: parseNumber
  },
  {
    test: (value) => /^[£$€?.]/.test(value),
    format: (value) => parseNumber(value.replace(/[£$€]/g, ''))
  },
  {
    test: (value) => /^\d{4}[/-]\d{1,2}[/-]\d{1,2}$/.test(value),
    format: (value) => parseDate(value.replace(/-/g, '/'))
  },
  {
    test: (value) => /%$/.test(value.trim()),
    format: (value) => parseNumber(value.replace(/%/g, ''))
  },
  {
    test: (value) => /\d{1,2}[/-]\d{1,2}[/-]\d{2,4}/.test(value),
    format: (value) =>
      parseDate(
        value
          .replace(/-/g, '/')
          .replace(/(\d{1,2})\/(\d{1,2})\/(\d{4})/, '$3/$1/$2')
      )
  }
].map((parser) => ({ ...parser, type: 'numeric' }))

function getCellValue(cell) {
  if (!cell) return ''

  return cell.dataset.sortValue ?? cell.textContent
}

function getColumnIndex(th) {
  let index = 0
  let sibling = th.previousElementSibling

  while (sibling) {
    index += sibling.colSpan
    sibling = sibling.previousElementSibling
  }

  return index
}

function getRows(table) {
  return [...table.tBodies].flatMap((tbody) => [...tbody.rows])
}

function detectParser(rows, columnIndex) {
  const sample =
    rows
      .map((row) => getCellValue(row.cells[columnIndex]).trim())
      .find((value) => value !== '') ?? ''

  return numericParsers.find((parser) => parser.test(sample)) || textParser
}

function getParsers(table) {
  if (!parsersByTable.has(table)) {
    const rows = getRows(table)
    const columnCount = Math.max(0, ...rows.map((row) => row.cells.length))
    const parsers = Array.from({ length: columnCount }, (_, index) =>
      detectParser(rows, index)
    )

    parsersByTable.set(table, parsers)
  }

  return parsersByTable.get(table)
}

function nextDirection(th) {
  const count = directionCountByHeader.get(th) || 0

  directionCountByHeader.set(th, count + 1)

  return count % 2 === 0 ? ASCENDING : DESCENDING
}

function compareValues(a, b, type) {
  return type === 'text' ? a.localeCompare(b) : a - b
}

function sortTbody(tbody, columnIndex, parser, direction) {
  const modifier = direction === ASCENDING ? 1 : -1
  const rows = [...tbody.rows].map((row) => ({
    row,
    value: parser.format(getCellValue(row.cells[columnIndex]))
  }))

  rows.sort(
    (a, b) => compareValues(a.value, b.value, parser.type) * modifier
  )

  tbody.append(...rows.map(({ row }) => row))
}

function updateHeaders(table, th, direction) {
  table.tHead
    .querySelectorAll('th[aria-sort]')
    .forEach((header) => header.removeAttribute('aria-sort'))

  th.setAttribute('aria-sort', direction)
}

export function sortTableByHeader(th) {
  const table = th.closest('table')

  if (!getRows(table).length) return

  const columnIndex = getColumnIndex(th)
  const parser = getParsers(table)[columnIndex] || textParser
  const direction = nextDirection(th)

  ;[...table.tBodies].forEach((tbody) =>
    sortTbody(tbody, columnIndex, parser, direction)
  )

  updateHeaders(table, th, direction)
}
