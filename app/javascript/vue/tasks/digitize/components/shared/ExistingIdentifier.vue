<template>
  <div
    v-if="existingIdentifiers.length"
    class="separate-top"
  >
    <span class="text-error-color">
      Identifier already exists, and it won't be saved:
    </span>
    <div class="horizontal-left-content gap-small middle">
      <a
        :href="existingIdentifiers[0].identifier_object.object_url"
        v-html="existingIdentifiers[0].identifier_object.object_tag"
      />
      <VBtn
        v-if="collectionObjectId"
        color="primary"
        medium
        @click="emit('load', collectionObjectId)"
      >
        Load
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { COLLECTION_OBJECT } from '@/constants'
import VBtn from '@/components/ui/VBtn/index.vue'

const props = defineProps({
  existingIdentifiers: {
    type: Array,
    default: () => []
  }
})

const emit = defineEmits(['load'])

const collectionObjectId = computed(() => {
  const existing = props.existingIdentifiers[0]

  return existing?.identifier_object_type === COLLECTION_OBJECT
    ? existing.identifier_object_id
    : undefined
})
</script>
