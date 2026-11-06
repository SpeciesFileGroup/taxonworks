<template>
  <div class="panel content margin-medium-bottom">
    <div class="flex-row flex-separate middle gap-medium">
      <div class="horizontal-left-content gap-medium flex-wrap-row">
        <span>
          <strong>{{ total.toLocaleString() }}</strong> {{ totalLabel }}
        </span>
        <VBadge
          v-for="item in shownItems"
          :key="item.key"
          class="status-summary-badge"
          :color="item.color"
        >
          {{ item.count.toLocaleString() }} {{ item.label }}
        </VBadge>
      </div>

      <slot />
    </div>

    <slot name="notes" />
  </div>
</template>

<script setup>
// Batch load counts per status, with a slot for actions (e.g. a Create
// button) and one for notes below.
import { computed } from 'vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'

const props = defineProps({
  total: {
    type: Number,
    required: true
  },

  totalLabel: {
    type: String,
    default: 'rows'
  },

  // [{ key, label, color (a VBadge color), count }]
  items: {
    type: Array,
    required: true
  },

  hideZero: {
    type: Boolean,
    default: true
  }
})

const shownItems = computed(() =>
  props.hideZero ? props.items.filter((item) => item.count) : props.items
)
</script>

<style scoped>
.status-summary-badge {
  white-space: nowrap;
}
</style>
