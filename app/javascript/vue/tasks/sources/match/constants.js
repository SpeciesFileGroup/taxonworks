import { FILTER_ALL } from '@/composables/usePagedList.js'

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

// Input columns are recognized by these names only (see InputPanel's
// `normalizeHeader`); any other column is ignored. Tooltips for the example
// table, only where they add something the example rows don't show.
export const FIELD_HELP = {
  [FIELD.VERBATIM]:
    'Split into authors, year, and the rest where possible',
  [FIELD.YEAR]: 'May have a letter suffix, e.g. 1936a',
  [FIELD.VOLUME]: 'May include issue and pages, e.g. 10(2):149-158',
  [FIELD.PAGES]: "The first page is compared: it agrees with the Source's first page, or a page within its range",
  [FIELD.DOI]: 'With or without https://doi.org/'
}

export const STATUS = {
  MATCHED: 'matched',
  AMBIGUOUS: 'ambiguous',
  UNMATCHED: 'unmatched',
  SELECTED: 'selected',
  NO_MATCH: 'no_match', // the user said none of the candidates is it
  EMPTY: 'empty'
}

export const STATUS_LABELS = {
  [STATUS.MATCHED]: 'Matched',
  [STATUS.AMBIGUOUS]: 'Ambiguous',
  [STATUS.UNMATCHED]: 'Unmatched',
  [STATUS.SELECTED]: 'User selected',
  [STATUS.NO_MATCH]: 'No match (user)',
  [STATUS.EMPTY]: 'Empty'
}

export const STATUS_BADGE_COLORS = {
  [STATUS.MATCHED]: 'green',
  [STATUS.AMBIGUOUS]: 'yellow',
  [STATUS.UNMATCHED]: 'red',
  [STATUS.SELECTED]: 'blue',
  [STATUS.NO_MATCH]: 'red',
  [STATUS.EMPTY]: 'default'
}

export const ROW_FILTER = {
  ALL: FILTER_ALL,
  MATCHED: STATUS.MATCHED,
  AMBIGUOUS: STATUS.AMBIGUOUS,
  UNMATCHED: STATUS.UNMATCHED,
  SELECTED: STATUS.SELECTED,
  NO_MATCH: STATUS.NO_MATCH,
  NOT_IN_PROJECT: 'not_in_project'
}

export const ROW_FILTER_LABELS = {
  [ROW_FILTER.ALL]: 'All',
  [ROW_FILTER.MATCHED]: 'Matched',
  [ROW_FILTER.AMBIGUOUS]: 'Ambiguous',
  [ROW_FILTER.UNMATCHED]: 'Unmatched',
  [ROW_FILTER.SELECTED]: 'User selected',
  [ROW_FILTER.NO_MATCH]: 'No match (user)',
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

// The most the fuzzy option allows, as the server's
// Match::Source::Field::Authors::MAX_EDITS: a candidate's
// matched_author_counts has one entry for each of 0..MAX_AUTHOR_EDITS.
export const MAX_AUTHOR_EDITS = 3

// The server gathers candidates up to this many years from a row's year.
export const MAX_YEAR_TOLERANCE = 2

// A fresh object each call, so callers never share mutable state.
export function defaultOptions() {
  return {
    limitToProject: false,
    preferProjectSources: true,
    yearTolerance: 0,
    matchYearSuffix: false,
    authorScope: AUTHOR_SCOPE.ROW,
    authorMatching: AUTHOR_MATCHING.FUZZY,
    authorMaxEdits: 1,
    requireFirstAuthorInitials: true,
    minTitleSimilarity: 0.6,
    minJournalSimilarity: 0,
    requireVolume: true,
    requirePage: true
  }
}
