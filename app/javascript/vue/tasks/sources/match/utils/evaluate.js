import {
  AUTHOR_MATCHING,
  MAX_AUTHOR_EDITS,
  AUTHOR_SCOPE,
  CHECK,
  STATUS
} from '../constants.js'
import { pluralize } from '../../../../helpers/strings.js'

// The server (Match::Source::Candidates) gathers candidates, measures how
// each compares to its row, and judges what doesn't depend on the options
// (e.g. `corroborated`). Only the user's Match options are applied here, so
// that changing them re-evaluates every row without matching again.

// One entry per compared field: how a candidate is checked, and what that
// check requires under the options, in words (shown in Match options). Keep
// each `requirements` in step with its `check` - they read the same options.
//
// check: (candidate, parsed, options) => [CHECK, detail]
// requirements: options => [String], empty when nothing is required
const FIELD_RULES = [
  {
    field: 'doi',
    check: doiCheck,
    requirements: () => []
  },
  {
    field: 'year',
    check: yearCheck,
    requirements: yearRequirements
  },
  {
    field: 'authors',
    check: authorCheck,
    requirements: authorRequirements
  },
  {
    field: 'title',
    check: (candidate, _, options) =>
      similarityCheck(candidate.title_similarity, options.minTitleSimilarity),
    requirements: (options) =>
      similarityRequirements('title', options.minTitleSimilarity)
  },
  {
    field: 'journal',
    check: (candidate, _, options) =>
      similarityCheck(
        candidate.journal_similarity,
        options.minJournalSimilarity
      ),
    requirements: (options) =>
      similarityRequirements('journal', options.minJournalSimilarity)
  },
  {
    field: 'volume',
    check: (candidate, _, options) =>
      equalityCheck(candidate.volume_match, options.requireVolume),
    requirements: (options) =>
      equalityRequirements('volume', options.requireVolume)
  },
  {
    field: 'firstPage',
    check: (candidate, _, options) =>
      equalityCheck(candidate.first_page_match, options.requireFirstPage),
    requirements: (options) =>
      equalityRequirements('first page', options.requireFirstPage)
  }
]

// What a candidate has to satisfy under the options, in words.
//
// @return [String]
export function describeRequirements(options) {
  return FIELD_RULES.flatMap(({ requirements }) => requirements(options))
}

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

  FIELD_RULES.forEach(({ field, check }) => {
    ;[checks[field], details[field]] = check(candidate, parsed, options)
  })

  const passes =
    checks.doi === CHECK.PASS ||
    Object.values(checks).every((check) => check !== CHECK.FAIL)

  return { checks, details, passes }
}

// Options apply before the user's selection: a selected Source outside the
// scope (not in the project, when only this project's Sources are matched)
// is set aside, not forgotten - the row is evaluated as if nothing were
// selected, and the selection is back when the scope allows it.
//
// "None of these" (row.noMatch) is a selection too, and never set aside.
//
// @param row - { parsed, candidates, fixedSource, noMatch, isEmpty }
// @return { status, source, evaluations, selectionOutOfScope } - source is
//   the chosen candidate's `source` (or the user's pick), evaluations
//   parallel row.candidates
export function evaluateRow(row, options) {
  if (row.isEmpty) {
    return { status: STATUS.EMPTY, source: null, evaluations: [] }
  }

  const evaluations = (row.candidates || []).map((candidate) =>
    evaluateCandidate(candidate, row.parsed || {}, options)
  )

  if (row.noMatch) {
    return { status: STATUS.NO_MATCH, source: null, evaluations }
  }

  const selectionOutOfScope =
    !!row.fixedSource &&
    options.limitToProject &&
    row.fixedSource.in_project === false

  if (row.fixedSource && !selectionOutOfScope) {
    return { status: STATUS.SELECTED, source: row.fixedSource, evaluations }
  }

  return { ...automaticResult(row, evaluations, options), selectionOutOfScope }
}

function automaticResult(row, evaluations, options) {
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

  if (passing.length > 1) {
    const inProject = passing.filter((c) => c.in_project)
    if (options.preferProjectSources && inProject.length === 1) {
      return { status: STATUS.MATCHED, source: sourceOf(inProject[0]), evaluations }
    }

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
export function sourceOf(candidate) {
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

  // The row has a year the Source doesn't.
  if (candidate.year_difference == null) {
    return [CHECK.FAIL, 'Source has no year']
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

function yearRequirements(options) {
  const year = options.yearTolerance
    ? `the year is within ±${options.yearTolerance}`
    : 'the year is the same'

  return [
    `${year} (the Source must have one, when the row has)`,
    options.matchYearSuffix
      ? 'year suffixes (1990a, 1990b) agree, when both have one'
      : null
  ].filter(Boolean)
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
    return [
      CHECK.FAIL,
      `First author differs (${firstAuthorDetail(candidate)})`
    ]
  }

  // Same surname, different person: Smit, F.G.A.M. vs Smit, B.
  const initialsConflict = candidate.first_author_initials_match === false
  const initialsDetail = initialsConflict
    ? `First author initials differ (${formatInitials(
        parsed.first_author_initials
      )} vs ${formatInitials(candidate.source_first_author_initials)})`
    : null

  if (initialsConflict && options.requireFirstAuthorInitials) {
    return [CHECK.FAIL, initialsDetail]
  }

  // Row authors each paired with a different Source author, within maxEdits.
  const matchedCount = candidate.matched_author_counts[maxEdits]
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
    allMatch && candidate.first_author_exact && !initialsConflict
      ? CHECK.PASS
      : CHECK.DIFFERS,
    [
      `First author ${firstAuthorDetail(candidate)}`,
      initialsDetail,
      allDetail
    ]
      .filter(Boolean)
      .join('; ')
  ]
}

function authorRequirements(options) {
  const spelling = {
    [AUTHOR_MATCHING.EXACT]: 'spelled identically',
    [AUTHOR_MATCHING.FOLDED]: 'ignoring diacritics and case',
    [AUTHOR_MATCHING.FUZZY]: `allowing up to ${options.authorMaxEdits} ${pluralize(options.authorMaxEdits, 'misspelling')} per surname`
  }[options.authorMatching]

  const authors = {
    [AUTHOR_SCOPE.FIRST]: 'the first author is the same',
    [AUTHOR_SCOPE.ROW]:
      'the first author is the same, and every other author in the row is in the Source',
    [AUTHOR_SCOPE.ALL]: 'the authors are the same'
  }[options.authorScope]

  return [
    `${authors} (${spelling})`,
    options.requireFirstAuthorInitials
      ? "the first author's initials share a letter, when both have initials"
      : null
  ].filter(Boolean)
}

// ['F', 'G'] -> 'F.G.'
function formatInitials(initials) {
  return (initials || []).map((letter) => `${letter}.`).join('')
}

// The server caps distances above MAX_AUTHOR_EDITS: 4 means 4 or more.
function firstAuthorDetail(candidate) {
  if (candidate.first_author_exact) return 'identical'
  const distance = candidate.first_author_distance
  if (distance === 0) return 'same ignoring diacritics/case'
  return `${distance}${distance > MAX_AUTHOR_EDITS ? '+' : ''} ${pluralize(distance, 'edit')}`
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

function similarityRequirements(label, minimum) {
  return minimum > 0
    ? [`the ${label} is at least ${Math.round(minimum * 100)}% similar`]
    : []
}

function equalityCheck(match, required) {
  if (match == null) return [CHECK.NONE, 'Not compared']
  if (match) return [CHECK.PASS, 'Same']
  return required ? [CHECK.FAIL, 'Differs'] : [CHECK.DIFFERS, 'Differs']
}

function equalityRequirements(label, required) {
  return required ? [`the ${label} is the same, when both have one`] : []
}
