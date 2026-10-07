// Parses CSV or TSV text (delimiter guessed from the header line) into
// { headers: [...], rows: [{ header: value }, ...] }. Quoted fields may
// contain delimiters, doubled quotes, and newlines.
export function parseDelimited(text) {
  const firstLine = text.split(/\r?\n/, 1)[0] || ''
  const delimiter = firstLine.includes('\t') ? '\t' : ','
  const records = parseRecords(text, delimiter).filter((fields) =>
    fields.some((f) => f.trim())
  )

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
