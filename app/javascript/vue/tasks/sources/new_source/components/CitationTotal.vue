<template>
  <div>
    <span
      class="feedback feedback-secondary feedback-thin line-nowrap"
      :title="`${total} citations in project`"
    >
      <span v-if="isLoading">Loading...</span>
      <span v-else>{{ total }} citations</span>
    </span>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Citation } from '@/routes/endpoints'

const props = defineProps({
  sourceId: {
    type: [String, Number],
    required: true
  }
})

const total = ref(0)
const isLoading = ref(false)

watch(
  () => props.sourceId,
  (newVal) => {
    if (newVal) {
      isLoading.value = true
      Citation.where({ source_id: props.sourceId, per: 1 })
        .then((response) => {
          total.value = Number(response.headers['pagination-total'])
        })
        .finally(() => {
          isLoading.value = false
        })
    } else {
      total.value = 0
    }
  },
  { immediate: true }
)
</script>
