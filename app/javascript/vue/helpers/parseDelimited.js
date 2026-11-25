// Parses CSV or TSV text (delimiter guessed from the header line) into
// { headers: [...], rows: [{ header: value }, ...] }. Quoted fields may
// contain delimiters, doubled quotes, and newlines.
//
// Blank rows are dropped unless keepBlankRows, in which case only those
// before the header and trailing ones are, so that rows line up with the
// input's lines.
export function parseDelimited(text, { keepBlankRows = false } = {}) {
  const headerLine = text.split(/\r?\n/).find((l) => l.trim()) || ''
  const delimiter = headerLine.includes('\t') ? '\t' : ','
  const isBlank = (fields) => !fields.some((f) => f.trim())
  let records = parseRecords(text, delimiter)

  if (keepBlankRows) {
    while (records.length && isBlank(records[0])) records.shift()
    while (records.length && isBlank(records.at(-1))) records.pop()
  } else {
    records = records.filter((fields) => !isBlank(fields))
  }

  if (!records.length) {
    return { headers: [], rows: [] }
  }

  const headers = records[0].map((h) => h.trim())
  const rows = records.slice(1).map((fields) => {
    const row = {}
    headers.forEach((header, i) => {
      row[header] = (fields[i] || '').trim()
    })
    return row
  })

  return { headers, rows }
}

function parseRecords(text, delimiter) {
  const records = []
  let fields = []
  let current = ''
  let inQuotes = false

  for (let i = 0; i < text.length; i++) {
    const char = text[i]

    if (inQuotes) {
      if (char === '"') {
        if (text[i + 1] === '"') {
          current += '"'
          i++
        } else {
          inQuotes = false
        }
      } else {
        current += char
      }
    } else if (char === '"' && current === '') {
      inQuotes = true
    } else if (char === delimiter) {
      fields.push(current)
      current = ''
    } else if (char === '\n' || char === '\r') {
      if (char === '\r' && text[i + 1] === '\n') i++
      fields.push(current)
      records.push(fields)
      fields = []
      current = ''
    } else {
      current += char
    }
  }

  if (current !== '' || fields.length) {
    fields.push(current)
    records.push(fields)
  }

  return records
}
