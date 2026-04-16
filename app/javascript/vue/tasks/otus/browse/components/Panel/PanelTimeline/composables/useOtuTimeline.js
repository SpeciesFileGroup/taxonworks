import { Otu } from '@/routes/endpoints'
import { ref, watch } from 'vue'

export default function useOtuTimeline(otuRef, { defaultTab } = {}) {
  const isLoading = ref(false)
  const timeline = ref()
  const selectedReferenceIds = ref([])
  const selectedTopics = ref([])
  const tab = ref(defaultTab)

  const reset = () => {
    selectedReferenceIds.value = []
    selectedTopics.value = []
    tab.value = defaultTab
  }

  watch(
    otuRef,
    (otu) => {
      if (!otu) return

      reset()
      isLoading.value = true

      Otu.timeline(otu.id)
        .then(({ body }) => {
          timeline.value = body
        })
        .finally(() => {
          isLoading.value = false
        })
    },
    { immediate: true }
  )

  return {
    isLoading,
    timeline,
    selectedReferenceIds,
    selectedTopics,
    tab
  }
}
