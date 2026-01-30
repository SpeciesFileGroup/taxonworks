<template>
  <div class="packager-header margin-medium-top">
    <VBtn
      :disabled="!canGoBack"
      color="primary"
      @click="onBack"
    >
      Back to {{ filterName }}
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'

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

const emit = defineEmits(['back'])

function onBack() {
  emit('back')
}
</script>

<style scoped>
.packager-header {
  text-align: right;
}
</style>
