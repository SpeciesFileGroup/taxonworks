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

// What the server made of the row, for spotting bad parses.
export function parsedSummary(parsed) {
  if (!parsed) return ''

  const volumePage = [parsed.volume, parsed.first_page]
    .filter(Boolean)
    .join(':')

  return [
    parsed.surnames?.join(', '),
    parsed.year ? `${parsed.year}${parsed.year_suffix || ''}` : null,
    volumePage,
    parsed.doi
  ]
    .filter(Boolean)
    .join(' · ')
}
