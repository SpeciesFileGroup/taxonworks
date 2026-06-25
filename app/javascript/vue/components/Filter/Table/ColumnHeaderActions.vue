<template>
  <div class="horizontal-left-content gap-small">
    <VLock
      :value="columnKey"
      v-model="freeze"
    />
    <VBtn
      color="primary"
      icon
      variant="tonal"
      title="Copy column to clipboard"
      @click.stop="emit('copy')"
    >
      <IconCopy class="w-3 h-3" />
    </VBtn>
    <VBtn
      title="Sort alphabetically"
      color="primary"
      icon
      variant="tonal"
      @click.stop="emit('sort')"
    >
      <VIcon
        name="alphabeticalSort"
        x-small
      />
    </VBtn>
    <VBtn
      v-if="filtered"
      color="toggle-active"
      circle
      @click.stop="emit('clear')"
    >
      X
    </VBtn>
  </div>
</template>

<script setup>
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VLock from '@/components/ui/VLock/index.vue'
import IconCopy from '@/components/Icon/IconCopy.vue'

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
