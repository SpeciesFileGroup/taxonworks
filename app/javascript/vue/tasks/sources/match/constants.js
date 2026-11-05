export const MAX_ROWS = 3000

// Rows sent per /sources/match request; the server allows at most 500.
export const CHUNK_SIZE = 200

export const ROWS_PER_PAGE = 100

export const FIELD = {
  VERBATIM: 'verbatim',
  AUTHORS: 'authors',
  YEAR: 'year',
  TITLE: 'title',
  JOURNAL: 'journal',
  VOLUME: 'volume',
  PAGES: 'pages',
  DOI: 'doi'
}

export const FIELD_LABELS = {
  [FIELD.VERBATIM]: 'Verbatim citation',
  [FIELD.AUTHORS]: 'Authors',
  [FIELD.YEAR]: 'Year',
  [FIELD.TITLE]: 'Title',
  [FIELD.JOURNAL]: 'Journal',
  [FIELD.VOLUME]: 'Volume (may include issue and pages)',
  [FIELD.PAGES]: 'Pages',
  [FIELD.DOI]: 'DOI'
}

// Column headers, lowercased with non-letters removed, that are mapped to a
// field by default.
export const HEADER_ALIASES = {
  verbatim: FIELD.VERBATIM,
  citation: FIELD.VERBATIM,
  reference: FIELD.VERBATIM,
  bibliographiccitation: FIELD.VERBATIM,
  author: FIELD.AUTHORS,
  authors: FIELD.AUTHORS,
  authorship: FIELD.AUTHORS,
  year: FIELD.YEAR,
  title: FIELD.TITLE,
  journal: FIELD.JOURNAL,
  serial: FIELD.JOURNAL,
  periodical: FIELD.JOURNAL,
  volume: FIELD.VOLUME,
  vol: FIELD.VOLUME,
  volissue: FIELD.VOLUME,
  volumeissue: FIELD.VOLUME,
  pages: FIELD.PAGES,
  page: FIELD.PAGES,
  doi: FIELD.DOI
}

export const STATUS = {
  MATCHED: 'matched',
  AMBIGUOUS: 'ambiguous',
  UNMATCHED: 'unmatched',
  SELECTED: 'selected',
  EMPTY: 'empty'
}

export const STATUS_LABELS = {
  [STATUS.MATCHED]: 'Matched',
  [STATUS.AMBIGUOUS]: 'Ambiguous',
  [STATUS.UNMATCHED]: 'Unmatched',
  [STATUS.SELECTED]: 'User selected',
  [STATUS.EMPTY]: 'Empty'
}

export const STATUS_BADGE_COLORS = {
  [STATUS.MATCHED]: 'green',
  [STATUS.AMBIGUOUS]: 'yellow',
  [STATUS.UNMATCHED]: 'red',
  [STATUS.SELECTED]: 'blue',
  [STATUS.EMPTY]: 'default'
}

export const ROW_FILTER = {
  ALL: 'all',
  MATCHED: STATUS.MATCHED,
  AMBIGUOUS: STATUS.AMBIGUOUS,
  UNMATCHED: STATUS.UNMATCHED,
  SELECTED: STATUS.SELECTED,
  NOT_IN_PROJECT: 'not_in_project'
}

export const ROW_FILTER_LABELS = {
  [ROW_FILTER.ALL]: 'All',
  [ROW_FILTER.MATCHED]: 'Matched',
  [ROW_FILTER.AMBIGUOUS]: 'Ambiguous',
  [ROW_FILTER.UNMATCHED]: 'Unmatched',
  [ROW_FILTER.SELECTED]: 'User selected',
  [ROW_FILTER.NOT_IN_PROJECT]: 'Source not in project'
}

// How a single field of a candidate compares to its row.
export const CHECK = {
  PASS: 'pass', // agrees
  DIFFERS: 'differs', // disagrees, but the options don't require it to agree
  FAIL: 'fail', // disagrees and the options require it to agree
  NONE: 'none' // not compared, missing from the row or the Source
}

export const AUTHOR_SCOPE = {
  FIRST: 'first', // the row's first author is the Source's first author
  ROW: 'row', // ... and every other author in the row is in the Source
  ALL: 'all' // ... and the Source has no others
}

export const AUTHOR_SCOPE_OPTIONS = [
  { value: AUTHOR_SCOPE.FIRST, label: 'First author agrees' },
  {
    value: AUTHOR_SCOPE.ROW,
    label: 'First author agrees, and all others in the row are in the Source',
    description: 'Allows rows that list only some authors (et al.).'
  },
  { value: AUTHOR_SCOPE.ALL, label: 'Same authors' }
]

export const AUTHOR_MATCHING = {
  EXACT: 'exact',
  FOLDED: 'folded',
  FUZZY: 'fuzzy'
}

export const AUTHOR_MATCHING_OPTIONS = [
  {
    value: AUTHOR_MATCHING.EXACT,
    label: 'Exact',
    description: 'Surnames spelled identically.'
  },
  {
    value: AUTHOR_MATCHING.FOLDED,
    label: 'Ignore diacritics and case',
    description:
      'Müller = Muller, De Long = DeLong; name particles are optional ' +
      '(van der Merwe = Merwe).'
  },
  {
    value: AUTHOR_MATCHING.FUZZY,
    label: 'Fuzzy',
    description: 'As above, also allowing misspellings.'
  }
]

// The server reports author edit distances up to this.
export const MAX_AUTHOR_EDITS = 3

// The server gathers candidates up to this many years from a row's year.
export const MAX_YEAR_TOLERANCE = 2

// A fresh object each call, so callers never share mutable state.
export function defaultOptions() {
  return {
    limitToProject: false,
    preferProjectSources: true,
    yearTolerance: 0,
    requireYear: true,
    matchYearSuffix: false,
    authorScope: AUTHOR_SCOPE.ROW,
    authorMatching: AUTHOR_MATCHING.FOLDED,
    authorMaxEdits: 1,
    requireFirstAuthorInitials: true,
    minTitleSimilarity: 0.6,
    minJournalSimilarity: 0,
    requireVolume: true,
    requireFirstPage: true
  }
}
