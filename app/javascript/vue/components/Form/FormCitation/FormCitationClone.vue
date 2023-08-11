<template>
  <VBtn
    color="primary"
    medium
    @click="setLastCitation"
  >
    Clone my last citation
  </VBtn>
</template>

<script setup>
import { Citation } from '@/routes/endpoints'
import { getCurrentUserId } from '@/helpers/user'
import VBtn from '@/components/ui/VBtn/index.vue'

const emit = defineEmits(['clone'])

function setLastCitation() {
  Citation.where({ recent: true, per: 1, user_id: getCurrentUserId() }).then(
    ({ body }) => {
      const [mostRecentCitation] = body

      if (mostRecentCitation) {
        emit('clone', {
          pages: mostRecentCitation.pages,
          source_id: mostRecentCitation.source_id,
          is_original: mostRecentCitation.is_original
        })
      }
    }
  )
}
</script>
