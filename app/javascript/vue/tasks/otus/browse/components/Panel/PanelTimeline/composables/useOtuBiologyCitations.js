import { Otu } from '@/routes/endpoints'
import { ref, watch } from 'vue'

export default function useOtuBiologyCitations(otuRef) {
  const isLoading = ref(false)
  const inventory = ref([])

  watch(
    otuRef,
    (otu) => {
      inventory.value = []

      if (!otu) return

      isLoading.value = true

      Otu.citations(otu.id)
        .then(({ body }) => {
          inventory.value = body
        })
        .finally(() => {
          isLoading.value = false
        })
    },
    { immediate: true }
  )

  return {
    isLoading,
    inventory
  }
}
