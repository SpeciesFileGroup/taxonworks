import { ref, computed, watch } from 'vue'
import { Depiction } from '@/routes/endpoints'
import { OTU } from '@/constants'

export default (otuList) => {
  const depictions = ref([])
  const isLoading = ref(false)

  const depictionsByOtu = computed(() =>
    depictions.value.reduce((acc, d) => {
      acc[d.depiction_object_id] ||= []
      acc[d.depiction_object_id].push(d)

      return acc
    }, {})
  )

  async function loadDepictions(otus) {
    depictions.value = []

    if (!otus.length) return

    isLoading.value = true

    try {
      const { body } = await Depiction.all(
        {
          depiction_object_type: OTU,
          depiction_object_id: otus.map((otu) => otu.id)
        },
        { useFilter: true }
      )

      depictions.value = body
    } catch {
    } finally {
      isLoading.value = false
    }
  }

  watch(otuList, loadDepictions, { immediate: true })

  return {
    depictions,
    depictionsByOtu,
    isLoading
  }
}
