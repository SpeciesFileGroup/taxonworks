export const INAT_STATUS_FOUND = 'found'
export const INAT_STATUS_CREATED = 'created'
export const INAT_STATUS_NOT_IMPORTED = 'not_imported'
export const INAT_STATUS_ALREADY_IMPORTED = 'already_imported'
export const INAT_STATUS_NOT_FOUND = 'not_found'
export const INAT_STATUS_NO_TAXON = 'no_taxon'
export const INAT_STATUS_QUEUED = 'queued'

export const FIND_STATUS_LABELS = {
  [INAT_STATUS_FOUND]: (count) => `${count} found in this project`,
  [INAT_STATUS_NOT_IMPORTED]: (count) => `${count} not yet imported`,
  [INAT_STATUS_NOT_FOUND]: (count) => `${count} not found on iNaturalist`
}

export const IMPORT_STATUS_LABELS = {
  [INAT_STATUS_QUEUED]: (count) => `${count} queued`,
  [INAT_STATUS_ALREADY_IMPORTED]: (count) => `${count} already imported`,
  [INAT_STATUS_NOT_FOUND]: (count) => `${count} not found on iNaturalist`,
  [INAT_STATUS_NO_TAXON]: (count) => `${count} skipped (no taxon)`
}

export function summarizeStatuses(rows, labelMap) {
  return Object.entries(labelMap)
    .flatMap(([status, label]) => {
      const count = rows.filter((r) => r.status === status).length
      return count ? [label(count)] : []
    })
    .join('; ')
}
