import { ref } from 'vue'
import { ANATOMICAL_PART, OTU } from '@/constants'
import { stacksByOtu } from '../adapters/arrange'
import { loadAnatomicalPartOrigins, loadCurrentOtuIds } from './useApplyOtu'

async function otuStacks(items) {
  const depictions = items.flatMap((it) => it.meta.depictions || [])
  const otuLabels = new Map()

  depictions
    .filter((d) => d.depiction_object_type === OTU && d.depiction_object)
    .forEach((d) =>
      otuLabels.set(d.depiction_object_id, d.depiction_object.object_label)
    )

  const anatomicalPartOrigins = await loadAnatomicalPartOrigins(
    depictions
      .filter((d) => d.depiction_object_type === ANATOMICAL_PART)
      .map((d) => d.depiction_object_id)
  )

  const currentOtuIds = await loadCurrentOtuIds(
    [
      ...depictions.map((d) => ({
        type: d.depiction_object_type,
        id: d.depiction_object_id
      })),
      ...anatomicalPartOrigins.values()
    ],
    otuLabels
  )

  return stacksByOtu(items, {
    currentOtuIds,
    anatomicalPartOrigins,
    otuLabels
  })
}

export const ARRANGE_BY = [{ label: 'OTU', value: OTU, stacks: otuStacks }]

export function useArrange() {
  const isLoading = ref(false)

  async function stacksBy(value, items) {
    const option = ARRANGE_BY.find((o) => o.value === value)

    isLoading.value = true

    try {
      return await option.stacks(items)
    } finally {
      isLoading.value = false
    }
  }

  return { isLoading, stacksBy }
}
