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

// Values of the subgenus_matching param to /taxon_names/match
export const SUBGENUS_MATCHING = {
  WITH: 'with',
  WITHOUT: 'without',
  BOTH: 'both'
}

export const SUBGENUS_MATCHING_HELP =
  'Without subgenus, any subgenus (or section, series...) between genus ' +
  'and epithet is ignored; every species-group epithet present (species, ' +
  'subspecies, variety, form...) may match any of its three predicted ' +
  'gender-agreeing spellings — masculine, feminine, or neuter — instead of ' +
  'the exact spelling stored; and the genus may be either the current one ' +
  'or the genus a name was originally described in.'

export const SUBGENUS_MATCHING_OPTIONS = [
  {
    value: SUBGENUS_MATCHING.WITH,
    label: 'Try with subgenus',
    description: 'Match names as given.'
  },
  {
    value: SUBGENUS_MATCHING.WITHOUT,
    label: 'Try without subgenus',
    description:
      'If there is no match as given, retry ignoring subgenus; match ' +
      'against different gender endings and current/original genus.'
  },
  {
    value: SUBGENUS_MATCHING.BOTH,
    label: 'Try with and without subgenus',
    description:
      'Always try both, so a name matching different taxa with and ' +
      'without subgenus is reported as ambiguous.'
  }
]

// A fresh array/objects each call, so callers never share mutable state.
export function defaultModifiers() {
  return [
    { active: false, pattern: '^(\\S*\\s+\\S*).*', replacement: '$1' },
    { active: false, pattern: '', replacement: '' }
  ]
}
