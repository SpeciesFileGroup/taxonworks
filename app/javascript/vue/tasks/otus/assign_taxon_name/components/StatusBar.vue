<template>
  <div class="panel content margin-medium-bottom">
    <div class="flex-row flex-separate middle">
      <div class="horizontal-left-content gap-medium">
        <span>
          <strong>{{ total }}</strong> OTUs
        </span>
        <span class="matched-count">
          <strong>{{ matchedCount }}</strong> with candidates
        </span>
        <span class="unmatched-count">
          <strong>{{ unmatchedCount }}</strong> without
        </span>
        <span>
          <strong>{{ setCount }}</strong> set
        </span>
        <span
          v-if="ambiguousCount"
          class="ambiguous-count"
        >
          <strong>{{ ambiguousCount }}</strong> ambiguous
        </span>

        <span
          v-if="otuFilterUrl"
          class="subtle"
        >
          Scoped to {{ scopeTotal }} OTUs
          <a :href="otuFilterUrl">Back to filter</a>
        </span>

        <span
          v-if="taxonNameFilterUrl"
          class="subtle"
        >
          Matched against a taxon name filter result
          <a :href="taxonNameFilterUrl">Back to filter</a>
        </span>
      </div>

      <div class="horizontal-left-content middle gap-small">
        <ButtonClipboard
          :text="clipboardText"
          title="Copy OTU id, match string, and taxon name id columns"
        />
        <VBtn
          color="primary"
          medium
          title="Remove rows already set from this view"
          :disabled="!setCount"
          @click="$emit('clear-set-rows')"
        >
          Clear set rows
        </VBtn>
      </div>
    </div>

    <div class="progress-bar margin-small-top">
      <div
        class="progress-matched"
        :style="{ width: matchedPercent + '%' }"
      />
      <div
        class="progress-unmatched"
        :style="{ width: unmatchedPercent + '%' }"
      />
    </div>
  </div>
</template>

<script setup>
import { computed } from 'vue'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'
import VBtn from '@/components/ui/VBtn/index.vue'

const CLIPBOARD_HEADERS = ['otuId', 'match', 'taxonNameId']

const props = defineProps({
  rows: {
    type: Array,
    required: true
  },

  scopeTotal: {
    type: Number,
    default: 0
  },

  otuFilterUrl: {
    type: String,
    default: null
  },

  taxonNameFilterUrl: {
    type: String,
    default: null
  }
})

defineEmits(['clear-set-rows'])

const total = computed(() => props.rows.length)

const matchedCount = computed(
  () => props.rows.filter((r) => r.candidates.length).length
)

const unmatchedCount = computed(() => total.value - matchedCount.value)

const setCount = computed(() => props.rows.filter((r) => r.set).length)

const ambiguousCount = computed(() => props.rows.filter((r) => r.ambiguous).length)

const matchedPercent = computed(() =>
  total.value ? (matchedCount.value / total.value) * 100 : 0
)

const unmatchedPercent = computed(() =>
  total.value ? (unmatchedCount.value / total.value) * 100 : 0
)

const clipboardText = computed(() =>
  [
    CLIPBOARD_HEADERS.join('\t'),
    ...props.rows.map((row) =>
      [row.otuId, row.matchString || '', row.taxonNameId ?? ''].join('\t')
    )
  ].join('\n')
)
</script>

<style scoped>
.progress-bar {
  height: 8px;
  display: flex;
  border-radius: 4px;
  overflow: hidden;
  background-color: var(--border-color);
}

.progress-matched {
  background-color: var(--color-create);
  transition: width 0.3s;
}

.progress-unmatched {
  background-color: var(--text-muted-color);
  transition: width 0.3s;
}

.matched-count {
  color: var(--color-create);
}

/* No candidates is de-emphasis; ambiguity is a caution. Red stays reserved for destruction. */
.unmatched-count {
  color: var(--text-muted-color);
}

.ambiguous-count {
  color: var(--color-warning);
}
</style>
