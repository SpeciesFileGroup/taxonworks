<template>
  <StatusSummary
    :total="nonEmptyCount"
    :items="items"
    :hide-zero="false"
  >
    <div class="horizontal-left-content gap-small middle">
      <div
        class="horizontal-left-content middle"
        :data-help="`The ${sourceIds.length} matched and user selected ${pluralize(sourceIds.length, 'Source')} (${notInProjectCount} not in this project), sent to the Source filter - where they can be added to the project, among other things - or to filters of what cites them.`"
      >
        <span class="margin-small-right">Sources</span>
        <div class="square-brackets">
          <ul class="no_bullets context-menu">
            <li>
              <RadialFilter
                :disabled="!sourceIds.length"
                :ids="sourceIds"
                ids-description="matched and user selected Sources"
                :object-type="SOURCE"
                :extended-slices="EXTENDED_SLICES"
              />
            </li>
          </ul>
        </div>
      </div>
      <VBtn
        color="primary"
        medium
        title="Download the rows with source_id and match_status columns added. Ambiguous rows get no source_id unless a Source was selected."
        @click="emit('download')"
      >
        Download CSV
      </VBtn>
      <VBtn
        color="primary"
        medium
        :disabled="!counts[STATUS.UNMATCHED] && !counts[STATUS.NO_MATCH]"
        title="Download only the unmatched rows (including those you marked No match), e.g. for DOI lookup"
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
import RadialFilter from '@/components/radials/filter/radial.vue'
import { FILTER_SOURCE } from '@/components/radials/filter/constants/filterLinks'
import { SOURCE } from '@/constants'
import StatusSummary from '@/components/BatchLoad/StatusSummary.vue'
import { pluralize } from '@/helpers/strings.js'
import { STATUS, STATUS_BADGE_COLORS, STATUS_LABELS } from '../constants.js'

const COUNTED_STATUSES = [
  STATUS.MATCHED,
  STATUS.SELECTED,
  STATUS.AMBIGUOUS,
  STATUS.UNMATCHED,
  STATUS.NO_MATCH
]

const props = defineProps({
  // evaluateRow() results, every row
  evaluations: {
    type: Array,
    required: true
  },

  // matched and user selected, unique
  sourceIds: {
    type: Array,
    default: () => []
  },

  notInProjectCount: {
    type: Number,
    default: 0
  }
})

// The Source filter itself, besides the filters of what cites Sources.
const EXTENDED_SLICES = [{ ...FILTER_SOURCE, flattenQuery: true }]

const emit = defineEmits(['download', 'download-unmatched'])

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
