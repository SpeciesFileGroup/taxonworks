<template>
  <div class="horizontal-left-content gap-small">
    <VLock
      :value="columnKey"
      v-model="freeze"
    />
    <VBtn
      icon
      variant="outline"
      title="Copy column to clipboard"
      @click.stop="emit('copy')"
    >
      <IconCopy class="w-3 h-3" />
    </VBtn>
    <VBtn
      title="Sort alphabetically"
      icon
      variant="outline"
      @click.stop="emit('sort')"
    >
      <IconAlphabeticalSort class="w-4 h-4" />
    </VBtn>
    <VBtn
      v-if="filtered"
      color="toggle-active"
      icon
      title="Clear column filter"
      @click.stop="emit('clear')"
    >
      <IconClose class="w-3 h-3" />
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VLock from '@/components/ui/VLock/index.vue'
import IconCopy from '@/components/Icon/IconCopy.vue'
import IconClose from '@/components/Icon/IconClose.vue'
import IconAlphabeticalSort from '@/components/Icon/IconAlphabeticalSort.vue'

defineProps({
  columnKey: {
    type: String,
    required: true
  },

  filtered: {
    type: Boolean,
    default: false
  }
})

const freeze = defineModel('freeze', {
  type: Array,
  default: () => []
})

const emit = defineEmits(['copy', 'sort', 'clear'])
</script>
