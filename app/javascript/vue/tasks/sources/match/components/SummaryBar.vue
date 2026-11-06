<template>
  <StatusSummary
    :total="nonEmptyCount"
    :items="items"
    :hide-zero="false"
  >
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
  </StatusSummary>
</template>

<script setup>
import { computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import StatusSummary from '@/components/BatchLoad/StatusSummary.vue'
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

const items = computed(() =>
  COUNTED_STATUSES.map((status) => ({
    key: status,
    label: STATUS_LABELS[status].toLowerCase(),
    color: STATUS_BADGE_COLORS[status],
    count: counts.value[status] || 0
  }))
)

const nonEmptyCount = computed(
  () => props.evaluations.length - (counts.value[STATUS.EMPTY] || 0)
)
</script>
