<template>
  <div
    class="panel padding-large"
    :style="isLoading ? { minHeight: '300px', position: 'relative' } : {}"
  >
    <h2>Duplicates</h2>
    <div class="margin-medium-left">
      <VSpinner v-if="isLoading" />

      <template v-else-if="results.length > 0">
        <div
          v-for="section in sections"
          :key="section.key"
          class="margin-medium-bottom"
        >
          <h3>{{ section.label }}</h3>
          <table class="vue-table duplicates-table">
            <thead>
              <tr>
                <th>Category</th>
                <th class="count-col">Count</th>
              </tr>
            </thead>
            <tbody>
              <tr
                v-for="row in sectionRows(section.key)"
                :key="row.id"
              >
                <td>{{ row.text }}</td>
                <td class="count-col">
                  <a
                    v-if="row.count !== null"
                    :href="duplicatesUrl(row)"
                    target="_blank"
                    :class="['dup-count', countLevel(row.count)]"
                  >{{ row.count.toLocaleString() }}</a>
                  <span
                    v-else
                    class="dup-error"
                    title="Failed to load"
                  >—</span>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </template>

      <div v-else-if="!isLoading">
        No duplicates data available.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  projectId: {
    type: Number,
    required: true
  },
  datasetId: {
    type: Number,
    required: true
  }
})

const isLoading = ref(false)
const results = ref([])

const sections = [
  { key: 'species', label: 'Species' },
  { key: 'infraspecies', label: 'Infraspecies' },
  { key: 'higher_taxa', label: 'Higher taxa' }
]

onMounted(loadDuplicates)

watch(() => props.datasetId, loadDuplicates)

async function loadDuplicates() {
  isLoading.value = true
  try {
    const { body } = await ColdpExportPreference.checklistbankDuplicates(
      props.projectId,
      { checklistbank_dataset_id: props.datasetId }
    )
    results.value = Array.isArray(body) ? body : []
  } catch {
    results.value = []
  } finally {
    isLoading.value = false
  }
}

function sectionRows(sectionKey) {
  return results.value.filter((r) => r.section === sectionKey)
}

function countLevel(count) {
  if (count === 0) return 'level-ok'
  if (count <= 50) return 'level-warn'
  return 'level-error'
}

function duplicatesUrl(row) {
  return `https://www.checklistbank.org/dataset/${props.datasetId}/duplicates?_colCheck=${row.id}`
}
</script>

<style lang="scss" scoped>
.duplicates-table {
  width: 100%;

  th, td {
    padding: 0.4em 0.6em;
  }
}

.count-col {
  width: 6em;
  text-align: right;
}

.dup-count {
  display: inline-block;
  min-width: 3em;
  padding: 0.15em 0.5em;
  border-radius: 0.25em;
  text-align: center;
  font-weight: 600;
  color: white;
  text-decoration: none;

  &:hover {
    opacity: 0.85;
  }
}

.level-ok {
  background-color: #43a047;
}

.level-warn {
  background-color: #f9a825;
  color: #333;
}

.level-error {
  background-color: #e53935;
}

.dup-error {
  color: #999;
}
</style>
