<template>
  <div class="panel content margin-medium-bottom">
    <div class="flex-row flex-separate middle">
      <div class="horizontal-left-content gap-medium">
        <span>
          <strong>{{ totalRows }}</strong> rows
        </span>
        <span class="matched-count">
          <strong>{{ matchedCount }}</strong> matched
        </span>
        <span class="unmatched-count">
          <strong>{{ unmatchedCount }}</strong> unmatched
        </span>
        <span>
          <strong>{{ uniqueTaxonNameCount }}</strong> unique taxon names
        </span>
        <span>
          <strong>{{ uniqueOtuCount }}</strong> unique OTUs
        </span>
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

const props = defineProps({
  rows: {
    type: Array,
    required: true
  }
})

const totalRows = computed(() => props.rows.length)
const matchedCount = computed(() => props.rows.filter((r) => r.matched).length)
const unmatchedCount = computed(() => totalRows.value - matchedCount.value)

const matchedPercent = computed(() =>
  totalRows.value ? (matchedCount.value / totalRows.value) * 100 : 0
)
const unmatchedPercent = computed(() =>
  totalRows.value ? (unmatchedCount.value / totalRows.value) * 100 : 0
)

const uniqueTaxonNameCount = computed(() => {
  const ids = new Set()
  props.rows.forEach((r) => {
    if (r.taxonNameId) ids.add(r.taxonNameId)
  })
  return ids.size
})

const uniqueOtuCount = computed(() => {
  const ids = new Set()
  props.rows.forEach((r) => {
    if (r.selectedOtuId) ids.add(r.selectedOtuId)
  })
  return ids.size
})
</script>

<style scoped>
.progress-bar {
  height: 8px;
  display: flex;
  border-radius: 4px;
  overflow: hidden;
  background-color: #eee;
}

.progress-matched {
  background-color: #5cb85c;
  transition: width 0.3s;
}

.progress-unmatched {
  background-color: #d9534f;
  transition: width 0.3s;
}

.matched-count {
  color: #5cb85c;
}

.unmatched-count {
  color: #d9534f;
}
</style>
