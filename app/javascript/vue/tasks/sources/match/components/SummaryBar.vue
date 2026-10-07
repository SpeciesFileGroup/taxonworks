<template>
  <div class="panel content margin-medium-bottom">
    <div class="flex-row flex-separate middle gap-medium">
      <div class="horizontal-left-content gap-medium">
        <span>
          <strong>{{ nonEmptyCount }}</strong> rows
        </span>
        <span
          v-for="status in COUNTED_STATUSES"
          :key="status"
        >
          <VBadge :color="STATUS_BADGE_COLORS[status]">
            {{ counts[status] || 0 }} {{ STATUS_LABELS[status].toLowerCase() }}
          </VBadge>
        </span>
      </div>

      <div class="horizontal-left-content gap-small middle">
        <label
          class="middle"
          :data-help="`Matched and user selected Sources not yet in this project (${notInProjectCount} now) are added to it when downloading.`"
        >
          <input
            type="checkbox"
            v-model="addToProject"
          />
          Add Sources to project
        </label>
        <VBtn
          :color="addToProject && notInProjectCount ? 'create' : 'primary'"
          medium
          title="Download the rows with source_id and match_status columns added. Ambiguous rows get no source_id unless a Source was selected."
          @click="emit('download')"
        >
          Download CSV
        </VBtn>
        <VBtn
          color="primary"
          medium
          :disabled="!counts[STATUS.UNMATCHED]"
          title="Download only the unmatched rows, e.g. for DOI lookup"
          @click="emit('download-unmatched')"
        >
          Download unmatched
        </VBtn>
      </div>
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import { STATUS, STATUS_BADGE_COLORS, STATUS_LABELS } from '../constants.js'

const COUNTED_STATUSES = [
  STATUS.MATCHED,
  STATUS.SELECTED,
  STATUS.AMBIGUOUS,
  STATUS.UNMATCHED
]

const props = defineProps({
  // evaluateRow() results, every row
  evaluations: {
    type: Array,
    required: true
  },

  notInProjectCount: {
    type: Number,
    default: 0
  }
})

const emit = defineEmits(['download', 'download-unmatched'])

const addToProject = defineModel('addToProject', {
  type: Boolean,
  default: false
})

const counts = computed(() => {
  const result = {}
  props.evaluations.forEach(({ status }) => {
    result[status] = (result[status] || 0) + 1
  })
  return result
})

const nonEmptyCount = computed(
  () => props.evaluations.length - (counts.value[STATUS.EMPTY] || 0)
)
</script>
