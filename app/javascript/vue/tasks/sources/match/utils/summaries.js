import { FIELD } from '../constants.js'

const SUMMARY_FIELDS = [
  FIELD.VERBATIM,
  FIELD.AUTHORS,
  FIELD.YEAR,
  FIELD.TITLE,
  FIELD.JOURNAL,
  FIELD.VOLUME,
  FIELD.PAGES,
  FIELD.DOI
]

// The row's input as one line.
export function inputSummary(input) {
  return SUMMARY_FIELDS.map((field) => input[field])
    .filter(Boolean)
    .join(' · ')
}

// What the server read from the row - the values compared to each
// candidate - for spotting bad parses.
export function parsedSummary(parsed) {
  if (!parsed) return ''

  const parts = [
    ['authors', parsed.surnames?.join(', ')],
    ['year', parsed.year ? `${parsed.year}${parsed.year_suffix || ''}` : null],
    ['volume', parsed.volume],
    ['first page', parsed.first_page],
    ['DOI', parsed.doi]
  ].filter(([, value]) => value)

  if (!parts.length) return 'Read as: nothing recognized'

  return (
    'Read as: ' + parts.map(([label, value]) => `${label} ${value}`).join(' · ')
  )
}
