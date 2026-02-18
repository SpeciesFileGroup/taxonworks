<template>
  <div class="dwc-compact-summary panel content">
    <h3>Summary</h3>
    <table class="vue-table">
      <tbody>
        <tr>
          <td>Total rows (compacted)</td>
          <td>{{ meta.total_rows || rows.length }}</td>
        </tr>
        <tr>
          <td>Total individualCount</td>
          <td>{{ totalIndividualCount }}</td>
        </tr>
        <tr>
          <td>Unique scientificName values</td>
          <td>{{ uniqueScientificNames }}</td>
        </tr>
        <tr>
          <td>Preview mode</td>
          <td>{{ meta.preview ? 'Yes' : 'No' }}</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import { computed } from 'vue'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  },
  meta: {
    type: Object,
    default: () => ({})
  }
})

const totalIndividualCount = computed(() =>
  props.rows.reduce((sum, row) => sum + (parseInt(row.individualCount) || 0), 0)
)

const uniqueScientificNames = computed(
  () => new Set(props.rows.map((r) => r.scientificName).filter(Boolean)).size
)
</script>

<style scoped>
.dwc-compact-summary {
  margin-bottom: 1em;
}

.dwc-compact-summary table {
  max-width: 400px;
}

.dwc-compact-summary td:first-child {
  font-weight: bold;
  padding-right: 1em;
}
</style>
