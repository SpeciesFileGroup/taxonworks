<template>
  <div
    v-if="!isLoading"
    class="horizontal-left-content middle gap-small"
  >
    Publish content
    <VToggle
      :value="isPublic"
      v-model="isPublic"
      on-color="var(--color-create)"
      off-color="var(--color-destroy)"
      title="Unpublish / Publish"
      @click="makeContentPublish"
    />
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'
import { Content, PublicContent } from '@/routes/endpoints'
import VToggle from '@/components/ui/VToggle.vue'

const props = defineProps({
  contentId: {
    type: Number,
    required: true
  }
})

const isPublic = ref(false)
const isLoading = ref(false)

function makeContentPublish() {
  const payload = {
    content: {
      is_public: !isPublic.value
    }
  }

  Content.update(props.contentId, payload)
}

watch(
  () => props.contentId,
  (newVal) => {
    isLoading.value = true
    PublicContent.exists(newVal).then(({ body }) => {
      isPublic.value = body
      isLoading.value = false
    })
  },
  {
    immediate: true
  }
)
</script>
