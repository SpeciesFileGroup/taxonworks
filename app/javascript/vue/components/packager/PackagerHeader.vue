<template>
  <div class="packager-header flex-separate middle margin-medium-top">
    <div>
      <p>
        Individual downloads are capped at {{ formatBytes(maxBytes, 0) }};
        you can specify a different maximum download size to the right.
      </p>
    </div>
    <VBtn
      :disabled="!canGoBack"
      color="primary"
      @click="$emit('back')"
    >
      Back to {{ filterName }}
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import { formatBytes } from './utils'

defineProps({
  maxBytes: {
    type: Number,
    required: true
  },
  filterName: {
    type: String,
    required: true
  },
  canGoBack: {
    type: Boolean,
    default: true
  }
})

defineEmits(['back'])
</script>
