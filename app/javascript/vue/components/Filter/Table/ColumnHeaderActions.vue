<template>
  <div class="horizontal-left-content gap-small">
    <VLock
      :value="columnKey"
      v-model="freeze"
    />
    <VBtn
      color="primary"
      circle
      title="Copy column to clipboard"
      @click.stop="emit('copy')"
    >
      <VIcon
        name="clip"
        x-small
      />
    </VBtn>
    <VBtn
      title="Sort alphabetically"
      color="primary"
      circle
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
