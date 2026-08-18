export const APPLY_CATEGORIES = [
  { key: 'tags', label: 'Tags' },
  { key: 'source', label: 'Source' },
  { key: 'attribution', label: 'Attribution' },
  { key: 'depiction', label: 'Depiction' },
  { key: 'pixel', label: 'Scale' }
]

const HAS_DATA_FOR_CATEGORY = {
  tags: (state) => !!state.tagsForImage.length,

  source: (state) => !!state.source,

  attribution: (state) =>
    Object.values(state.people).some((people) => people.length) ||
    !!state.license,

  depiction: (state) =>
    !!state.objectsForDepictions.length || !!state.depiction.caption.length,

  pixel: (state) => !!state.pixelsToCentimeter
}

/**
 * Applied/pending state of a single image, where `applied` lists the categories
 * already sent to the server for that image and `pending` the ones that are
 * defined in the panels but not applied to it yet.
 */
export default function imageAppliedStatus(state, imageId) {
  const appliedCategories = state.settings.appliedByImage[imageId] || {}
  const applied = []
  const pending = []

  APPLY_CATEGORIES.forEach(({ key, label }) => {
    if (appliedCategories[key]) {
      applied.push(label)
    } else if (HAS_DATA_FOR_CATEGORY[key](state)) {
      pending.push(label)
    }
  })

  return { applied, pending }
}
