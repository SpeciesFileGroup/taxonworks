import { STATUS } from '../constants.js'

// Which of a row's candidates are listed when the row is opened.
//
// Candidates that pass are listed; when none do, those the server marks
// `corroborated` (see Match::Source::Candidates::CORROBORATING_ALONE). The
// user's selection is always listed. The rest are shown on request.
//
// @param row - { candidates, fixedSource }
// @param evaluation - evaluateRow(row) result

export function anyPasses(evaluation) {
  return evaluation.evaluations.some((e) => e.passes)
}

// @param i - the candidate's index in row.candidates
export function isUnlisted(row, evaluation, i) {
  const candidate = row.candidates[i]
  if (row.fixedSource?.id === candidate.source.id) return false
  if (anyPasses(evaluation)) return !evaluation.evaluations[i].passes

  return !candidate.corroborated
}

// @param showAll - list the unlisted ones too
// @return [{ candidate, i }], i its index in row.candidates
export function listedCandidates(row, evaluation, showAll) {
  return row.candidates
    .map((candidate, i) => ({ candidate, i }))
    .filter(({ i }) => showAll || !isUnlisted(row, evaluation, i))
}

export function unlistedCount(row, evaluation) {
  return row.candidates.filter((_, i) => isUnlisted(row, evaluation, i))
    .length
}

// The candidate the options picked, when no selection is in effect.
export function isAutomaticPick(evaluation, candidate) {
  return (
    evaluation.status !== STATUS.SELECTED &&
    evaluation.source?.id === candidate.source.id
  )
}
