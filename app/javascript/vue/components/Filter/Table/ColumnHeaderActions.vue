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
      v-if="sortable"
      :color="sortDir ? 'toggle-active' : 'primary'"
      :title="sortTitle"
      circle
      @click.stop="(e) => emit('sort', { shiftKey: e.shiftKey })"
    >
      <VIcon
        :name="sortIconName"
        x-small
      />
      <sup
        v-if="sortIndex != null && showSortIndex"
        class="margin-xsmall-left"
      >{{ sortIndex + 1 }}</sup>
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
import { computed } from 'vue'

const props = defineProps({
  columnKey: {
    type: String,
    required: true
  },

  filtered: {
    type: Boolean,
    default: false
  },

  sortIndex: {
    type: Number,
    default: null
  },

  sortDir: {
    type: String,
    default: null
  },

  showSortIndex: {
    type: Boolean,
    default: false
  },

  sortable: {
    type: Boolean,
    default: true
  }
})

const freeze = defineModel('freeze', {
  type: Array,
  default: () => []
})

const emit = defineEmits(['copy', 'sort', 'clear'])

const sortIconName = computed(() => {
  if (props.sortDir === 'asc') return 'arrowUp'
  if (props.sortDir === 'desc') return 'arrowDown'
  return 'alphabeticalSort'
})

const sortTitle = computed(() => {
  const base = 'Sort by this column. Shift-click to add as additional sort key.'
  if (!props.sortDir) return base
  return `Current: ${props.sortDir === 'asc' ? 'ascending' : 'descending'}. ${base}`
})
</script>
