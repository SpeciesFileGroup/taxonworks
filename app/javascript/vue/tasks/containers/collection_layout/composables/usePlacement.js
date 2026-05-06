import { ref } from 'vue'
import { ContainerItem } from '@/routes/endpoints'

export function usePlacement() {
  const placeError = ref('')

  async function place(containerItemId, col, row, z = undefined) {
    placeError.value = ''
    const attrs = { disposition_x: col, disposition_y: row }
    if (z !== undefined) attrs.disposition_z = z

    let body
    try {
      ;({ body } = await ContainerItem.update(containerItemId, {
        container_item: attrs
      }))
    } catch (error) {
      const errors = error?.response?.body
      placeError.value = errors
        ? Object.values(errors).flat().join(', ')
        : 'Could not place container.'
      return false
    }

    if (!body?.id) {
      placeError.value = 'Could not place container.'
      return false
    }

    return true
  }

  function unplace(containerItemId) {
    return place(containerItemId, null, null, null)
  }

  function reset() {
    placeError.value = ''
  }

  return { placeError, place, unplace, reset }
}
