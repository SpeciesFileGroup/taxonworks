export const MAX_ROWS = 3000

export const TAXON_NAME_FILTER = {
  ALL: 'all',
  AMBIGUOUS: 'ambiguous',
  UNMATCHED: 'unmatched',
  MATCHED_TN: 'matched_tn',
  MATCHED_OTU: 'matched_otu'
}

export const TAXON_NAME_FILTER_LABELS = {
  [TAXON_NAME_FILTER.ALL]: 'All',
  [TAXON_NAME_FILTER.AMBIGUOUS]: 'Ambiguous',
  [TAXON_NAME_FILTER.UNMATCHED]: 'Unmatched',
  [TAXON_NAME_FILTER.MATCHED_TN]: 'Matched Taxon Names',
  [TAXON_NAME_FILTER.MATCHED_OTU]: 'Matched OTUs'
}

export const OTU_FILTER = {
  ALL: 'all',
  MULTIPLE: 'multiple',
  NO_OTU: 'no_otu',
  USER_SELECTED: 'selected'
}

export const OTU_FILTER_LABELS = {
  [OTU_FILTER.ALL]: 'All',
  [OTU_FILTER.MULTIPLE]: 'Multiple OTUs',
  [OTU_FILTER.NO_OTU]: 'No OTU',
  [OTU_FILTER.USER_SELECTED]: 'User selected'
}

// A fresh array/objects each call, so callers never share mutable state.
export function defaultModifiers() {
  return [
    { active: false, pattern: '^(\\S*\\s+\\S*).*', replacement: '$1' },
    { active: false, pattern: '', replacement: '' }
  ]
}
