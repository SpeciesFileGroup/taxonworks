<template>
  <VBadge
    class="composition-item composition-item--separator"
    :title="`Separator ${displaySeparator(separator.value)}`"
  >
    <span>{{ displaySeparator(separator.value) }}</span>
    <CompositionRemove @remove="emit('remove')" />
  </VBadge>
</template>

<script setup>
import { displaySeparator } from '../../utils/pattern'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import CompositionRemove from './CompositionRemove.vue'

defineProps({
  separator: {
    type: Object,
    required: true
  }
})

const emit = defineEmits(['remove'])
</script>
