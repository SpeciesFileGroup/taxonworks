<template>
  <div>
    <div
      v-if="isCountExceeded"
      class="feedback feedback-danger"
    >
      Too many records selected, maximum {{ MAX_LIMIT }}
    </div>

    <VBtn
      class="margin-large-top"
      color="create"
      medium
      :disabled="isCountExceeded"
      @click="regenerateDwC"
    >
      Update
    </VBtn>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { CollectionObject } from '@/routes/endpoints'

import VBtn from '@/components/ui/VBtn/index.vue'

const MAX_LIMIT = 10000

const props = defineProps({
  parameters: {
    type: Object,
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const isCountExceeded = computed(() => props.count > MAX_LIMIT)

function regenerateDwC() {
  CollectionObject.batchUpdateDwcOccurrence({
    collection_object_query: props.parameters
  }).catch(() => {})
}
</script>
