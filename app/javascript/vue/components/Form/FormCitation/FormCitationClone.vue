<template>
  <VBtn
    color="primary"
    medium
    icon
    variant="tonal"
    :disabled="disabled"
    :title="label"
    @click="setLastCitation"
  >
    <IconBookCopy class="w-4 h-4" />
  </VBtn>
</template>

<script setup>
import { Citation } from '@/routes/endpoints'
import { getCurrentUserId } from '@/helpers/user'
import VBtn from '@/components/ui/VBtn/index.vue'
import IconBookCopy from '@/components/Icon/IconBookCopy.vue'

defineProps({
  label: {
    type: String,
    default: 'Clone last citation'
  },

  disabled: {
    type: Boolean,
    default: false
  }
})

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
