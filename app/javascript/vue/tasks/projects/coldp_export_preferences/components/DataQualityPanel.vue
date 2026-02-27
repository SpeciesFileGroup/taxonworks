<template>
  <div class="panel padding-large">
    <h2>Health</h2>
    <div class="margin-medium-left">
      <div
        v-if="!otuId"
        class="feedback-warning padding-xsmall"
      >
        Save a profile with a root OTU first.
      </div>

      <template v-else>
        <VSpinner v-if="isLoading" />

        <template v-else-if="counts">
          <p class="health-hint">
            Valid names without an associated OTU will appear as "bare names" in ChecklistBank and will not be placed in the taxonomic classification.
            Use <a :href="synchronizeOtusPath">Synchronize taxon names to OTUs</a> to fix.
          </p>

          <table class="vue-table health-table">
            <tbody>
              <tr>
                <td>Valid names without OTU</td>
                <td class="num-col">
                  <a :href="synchronizeOtusPath">
                    {{ counts.valid_without.toLocaleString() }}
                  </a>
                </td>
              </tr>
              <template v-if="issueCounts">
                <tr>
                  <td>Errors</td>
                  <td class="num-col">
                    <a
                      :href="checklistbankIssuesUrl"
                      target="_blank"
                    >
                      {{ issueCounts.error.toLocaleString() }}
                    </a>
                  </td>
                </tr>
                <tr>
                  <td>Warnings</td>
                  <td class="num-col">
                    <a
                      :href="checklistbankIssuesUrl"
                      target="_blank"
                    >
                      {{ issueCounts.warning.toLocaleString() }}
                    </a>
                  </td>
                </tr>
                <tr>
                  <td>Info</td>
                  <td class="num-col">
                    <a
                      :href="checklistbankIssuesUrl"
                      target="_blank"
                    >
                      {{ issueCounts.info.toLocaleString() }}
                    </a>
                  </td>
                </tr>
              </template>
            </tbody>
          </table>

          <VBtn
            color="primary"
            class="margin-medium-top"
            :disabled="isLoading"
            @click="refresh"
          >
            Refresh
          </VBtn>
        </template>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, watch, computed } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'

const props = defineProps({
  projectId: {
    type: Number,
    required: true
  },
  otuId: {
    type: Number,
    default: null
  },
  datasetId: {
    type: Number,
    default: null
  }
})

const isLoading = ref(false)
const counts = ref(null)
const issueVocab = ref([])
const issuesData = ref(null)

const synchronizeOtusPath = '/tasks/taxon_names/synchronize_otus/index'

const checklistbankIssuesUrl = computed(() =>
  `https://www.checklistbank.org/dataset/${props.datasetId}/issues`
)

const issueCounts = computed(() => {
  if (!issuesData.value || !issueVocab.value.length) return null

  const issuesCount = issuesData.value.issuesCount || {}
  const totals = { error: 0, warning: 0, info: 0 }

  for (const [key, count] of Object.entries(issuesCount)) {
    const entry = issueVocab.value.find((v) => v.name === key)
    const level = entry?.level || 'warning'
    if (level in totals) {
      totals[level] += count
    } else {
      totals.warning += count
    }
  }

  return totals
})

onMounted(() => {
  if (props.otuId) loadCounts()
  if (props.datasetId) loadIssues()
  loadVocab()
})

watch(() => props.otuId, (val) => {
  if (val) loadCounts()
})

watch(() => props.datasetId, (val) => {
  if (val) loadIssues()
})

function refresh() {
  loadCounts()
  if (props.datasetId) loadIssues()
}

async function loadCounts() {
  isLoading.value = true
  try {
    const { body } = await ColdpExportPreference.missingOtusCount(
      props.projectId,
      { otu_id: props.otuId }
    )
    counts.value = body
  } catch {
    counts.value = null
  } finally {
    isLoading.value = false
  }
}

async function loadVocab() {
  try {
    const { body } = await ColdpExportPreference.issueVocab(props.projectId)
    issueVocab.value = body || []
  } catch {
    issueVocab.value = []
  }
}

async function loadIssues() {
  try {
    const { body } = await ColdpExportPreference.checklistbankIssues(
      props.projectId,
      { checklistbank_dataset_id: props.datasetId }
    )
    issuesData.value = body || null
  } catch {
    issuesData.value = null
  }
}
</script>

<style lang="scss" scoped>
.health-hint {
  opacity: 0.7;
  font-size: 0.9em;
  margin-bottom: 0.75em;
}

.health-table {
  width: 100%;

  td {
    padding: 0.4em 0.6em;
  }
}

.num-col {
  width: 6em;
  text-align: right;
}

</style>
