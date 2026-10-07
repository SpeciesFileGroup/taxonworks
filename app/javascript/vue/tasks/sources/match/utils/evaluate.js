import { AUTHOR_MATCHING, AUTHOR_SCOPE, CHECK, STATUS } from '../constants.js'

// Compares one candidate to its row, field by field, under the current
// options. A candidate passes when no field FAILs - or when its DOI agrees,
// which wins over everything else.
//
// @param candidate - one entry of a /sources/match row's `candidates`
// @param parsed - that row's `parsed` input
// @return { checks: { field: CHECK }, details: { field: String }, passes }
export function evaluateCandidate(candidate, parsed, options) {
  const checks = {}
  const details = {}

  ;[checks.doi, details.doi] = doiCheck(candidate)
  ;[checks.year, details.year] = yearCheck(candidate, parsed, options)
  ;[checks.authors, details.authors] = authorCheck(candidate, parsed, options)
  ;[checks.title, details.title] = similarityCheck(
    candidate.title_similarity,
    options.minTitleSimilarity
  )
  ;[checks.journal, details.journal] = similarityCheck(
    candidate.journal_similarity,
    options.minJournalSimilarity
  )
  ;[checks.volume, details.volume] = equalityCheck(
    candidate.volume_match,
    options.requireVolume
  )
  ;[checks.firstPage, details.firstPage] = equalityCheck(
    candidate.first_page_match,
    options.requireFirstPage
  )

  const passes =
    checks.doi === CHECK.PASS ||
    Object.values(checks).every((check) => check !== CHECK.FAIL)

  return { checks, details, passes }
}

// @param row - { parsed, candidates, fixedSource, isEmpty }
// @return { status, source, evaluations } - source is the chosen candidate's
//   `source` (or the user's pick), evaluations parallel row.candidates
export function evaluateRow(row, options) {
  if (row.isEmpty) {
    return { status: STATUS.EMPTY, source: null, evaluations: [] }
  }

  const evaluations = (row.candidates || []).map((candidate) =>
    evaluateCandidate(candidate, row.parsed || {}, options)
  )

  if (row.fixedSource) {
    return { status: STATUS.SELECTED, source: row.fixedSource, evaluations }
  }

  const passing = row.candidates.filter((_, i) => evaluations[i].passes)
  const byDoi = row.candidates.filter(
    (_, i) => evaluations[i].checks.doi === CHECK.PASS
  )

  if (byDoi.length === 1) {
    return { status: STATUS.MATCHED, source: sourceOf(byDoi[0]), evaluations }
  }

  if (passing.length === 1) {
    return { status: STATUS.MATCHED, source: sourceOf(passing[0]), evaluations }
  }

  if (passing.length > 1 && options.preferProjectSources) {
    const inProject = passing.filter((c) => c.in_project)
    if (inProject.length === 1) {
      return { status: STATUS.MATCHED, source: sourceOf(inProject[0]), evaluations }
    }
  }

  if (passing.length > 1) {
    // Candidates arrive best first.
    return {
      status: STATUS.AMBIGUOUS,
      source: sourceOf(passing[0]),
      evaluations
    }
  }

  return { status: STATUS.UNMATCHED, source: null, evaluations }
}

// The candidate's Source, with whether it is in the project.
function sourceOf(candidate) {
  return { ...candidate.source, in_project: candidate.in_project }
}

function doiCheck(candidate) {
  if (candidate.doi_match == null) return [CHECK.NONE, 'Not compared']
  // Two different DOIs are two different works.
  return candidate.doi_match
    ? [CHECK.PASS, 'Same DOI']
    : [CHECK.FAIL, 'Different DOI']
}

function yearCheck(candidate, parsed, options) {
  if (parsed.year == null) return [CHECK.NONE, 'No year in row']

  if (candidate.year_difference == null) {
    return options.requireYear
      ? [CHECK.FAIL, 'Source has no year']
      : [CHECK.NONE, 'Source has no year']
  }

  const difference = candidate.year_difference

  if (difference > options.yearTolerance) {
    return [CHECK.FAIL, `Years differ by ${difference}`]
  }

  if (options.matchYearSuffix && candidate.year_suffix_match === false) {
    return [CHECK.FAIL, 'Year suffixes differ']
  }

  return difference === 0
    ? [CHECK.PASS, 'Same year']
    : [CHECK.DIFFERS, `Years differ by ${difference}`]
}

function authorCheck(candidate, parsed, options) {
  if (!parsed.surnames?.length) return [CHECK.NONE, 'No authors in row']
  if (!candidate.source_author_count) return [CHECK.FAIL, 'Source has no authors']

  const maxEdits =
    options.authorMatching === AUTHOR_MATCHING.FUZZY
      ? options.authorMaxEdits
      : 0

  const firstPasses =
    options.authorMatching === AUTHOR_MATCHING.EXACT
      ? candidate.first_author_exact
      : candidate.first_author_distance <= maxEdits

  if (!firstPasses) {
    return [CHECK.FAIL, `First author differs (${firstAuthorDetail(candidate)})`]
  }

  const matchedCount = candidate.author_distances.filter(
    (d) => d != null && d <= maxEdits
  ).length
  const allDetail =
    `${matchedCount} of ${parsed.surnames.length} row authors found, ` +
    `Source has ${candidate.source_author_count}`

  const rowAuthorsFound = matchedCount === parsed.surnames.length
  const allMatch =
    rowAuthorsFound &&
    parsed.surnames.length === candidate.source_author_count

  if (
    (options.authorScope === AUTHOR_SCOPE.ROW && !rowAuthorsFound) ||
    (options.authorScope === AUTHOR_SCOPE.ALL && !allMatch)
  ) {
    return [CHECK.FAIL, allDetail]
  }

  return [
    allMatch && candidate.first_author_exact ? CHECK.PASS : CHECK.DIFFERS,
    `First author ${firstAuthorDetail(candidate)}; ${allDetail}`
  ]
}

function firstAuthorDetail(candidate) {
  if (candidate.first_author_exact) return 'identical'
  const distance = candidate.first_author_distance
  if (distance === 0) return 'same ignoring diacritics/case'
  return `${distance}${distance >= 4 ? '+' : ''} edit${distance === 1 ? '' : 's'}`
}

// Trigram similarity is noisy for short strings, so anything at or above
// this reads as agreeing even when no minimum is required.
const SIMILAR = 0.8

function similarityCheck(similarity, minimum) {
  if (similarity == null) return [CHECK.NONE, 'Not compared']

  const detail = `${Math.round(similarity * 100)}% similar`

  if (minimum > 0 && similarity < minimum) return [CHECK.FAIL, detail]
  if (similarity >= SIMILAR || (minimum > 0 && similarity >= minimum)) {
    return [CHECK.PASS, detail]
  }

  return [CHECK.DIFFERS, detail]
}

function equalityCheck(match, required) {
  if (match == null) return [CHECK.NONE, 'Not compared']
  if (match) return [CHECK.PASS, 'Same']
  return required ? [CHECK.FAIL, 'Differs'] : [CHECK.DIFFERS, 'Differs']
}
