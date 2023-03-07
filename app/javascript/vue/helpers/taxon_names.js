import { COMBINATION } from 'constants/index.js'

export function getTaxonNameStatus(taxon) {
  if (taxon.type === COMBINATION) {
    return '[c]'
  }

  return taxon.cached_is_valid ? '✓' : '❌'
}
