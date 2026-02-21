<template>
  <div class="panel padding-large">
    <h2>Issues</h2>
    <div class="margin-medium-left">
      <VSpinner v-if="isLoading" />

      <template v-else-if="sortedIssues.length > 0">
        <div class="issue-groups margin-medium-bottom">
          <span class="margin-small-right">Issue groups:</span>
          <button
            v-for="group in availableGroups"
            :key="group"
            :class="['issue-group-pill', { active: selectedGroups.has(group) }]"
            @click="toggleGroup(group)"
          >
            {{ groupLabel(group) }}
            <span
              v-if="selectedGroups.has(group)"
              class="pill-close"
            >&times;</span>
          </button>
        </div>

        <table class="vue-table">
          <thead>
            <tr>
              <th>Title</th>
              <th>Count</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="issue in filteredIssues"
              :key="issue.key"
            >
              <td>
                <span :class="['issue-badge', `issue-level-${issue.level}`]">
                  {{ issue.title }}
                </span>
                <a
                  :href="verbatimUrl(issue)"
                  target="_blank"
                  class="verbatim-link"
                >verbatim &#x2197;</a>
              </td>
              <td>
                <a
                  :href="`https://www.checklistbank.org/dataset/${datasetId}/names?issue=${issue.key}`"
                  target="_blank"
                  class="count-link"
                >{{ issue.count.toLocaleString() }}</a>
              </td>
            </tr>
          </tbody>
        </table>
      </template>

      <div v-else>
        No issues data available.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'

const CLB_ISSUE_VOCAB_URL = 'https://api.checklistbank.org/vocab/issue'

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
const issuesData = ref({})
const issueVocab = ref([])
const selectedGroups = ref(new Set())

onMounted(() => {
  loadIssues()
  loadVocab()
})

watch(() => props.datasetId, loadIssues)

async function loadVocab() {
  try {
    const response = await fetch(CLB_ISSUE_VOCAB_URL)
    issueVocab.value = await response.json()
  } catch {
    issueVocab.value = []
  }
}

async function loadIssues() {
  isLoading.value = true
  try {
    const { body } = await ColdpExportPreference.checklistbankIssues(
      props.projectId,
      { checklistbank_dataset_id: props.datasetId }
    )
    issuesData.value = body || {}
  } catch {
    issuesData.value = {}
  } finally {
    isLoading.value = false
  }
}

// Issue keys from CLB are already lowercase space-separated (e.g. "synonym rank differs"),
// matching the vocab name field directly.
function vocabEntry(issueKey) {
  return issueVocab.value.find((v) => v.name === issueKey)
}

function issueTitle(issueKey) {
  return issueKey
    .split(' ')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ')
}

const sortedIssues = computed(() => {
  const issues = issuesData.value.issuesCount || {}
  return Object.entries(issues)
    .map(([key, count]) => {
      const entry = vocabEntry(key)
      return {
        key,
        count,
        title: issueTitle(key),
        group: entry?.group || 'any',
        level: entry?.level || 'warning'
      }
    })
    .sort((a, b) => b.count - a.count)
})

const ALL_GROUPS = [
  'any', 'name', 'name usage', 'vernacular', 'distribution',
  'media', 'reference', 'treatment', 'estimate', 'type material',
  'species interaction', 'synonym'
]

const availableGroups = computed(() => ALL_GROUPS)

const filteredIssues = computed(() => {
  if (selectedGroups.value.size === 0) return sortedIssues.value
  return sortedIssues.value.filter((i) => selectedGroups.value.has(i.group))
})

function toggleGroup(group) {
  const next = new Set(selectedGroups.value)
  if (next.has(group)) {
    next.delete(group)
  } else {
    next.add(group)
  }
  selectedGroups.value = next
}

const GROUP_LABELS = {
  'any': 'Any',
  'name': 'Name',
  'name usage': 'NameUsage',
  'vernacular': 'Vernacular',
  'distribution': 'Distribution',
  'media': 'Media',
  'reference': 'Reference',
  'treatment': 'Treatment',
  'estimate': 'Estimate',
  'type material': 'TypeMaterial',
  'species interaction': 'SpeciesInteraction',
  'synonym': 'Synonym'
}

function groupLabel(group) {
  return GROUP_LABELS[group] || group
}

function verbatimUrl(issue) {
  const base = `https://www.checklistbank.org/dataset/${props.datasetId}/verbatim?issue=${encodeURIComponent(issue.key)}`

  if (selectedGroups.value.size === 0) return base

  // Use the issue's own group if it matches an active pill,
  // otherwise use the first active group.
  const group = selectedGroups.value.has(issue.group)
    ? issue.group
    : [...selectedGroups.value][0]

  if (group === 'any') return base

  const colType = 'col:' + group
    .split(' ')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join('')

  return `${base}&type=${encodeURIComponent(colType)}`
}
</script>

<style lang="scss" scoped>
.issue-groups {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 0.4em;
}

.issue-group-pill {
  display: inline-flex;
  align-items: center;
  gap: 0.3em;
  padding: 0.25em 0.7em;
  border: 1px solid #333;
  border-radius: 1em;
  background: white;
  color: #333;
  font-size: 0.85em;
  cursor: pointer;
  transition: all 0.15s;

  &:hover {
    background: #e0e0e0;
  }

  &.active {
    background: #4a90d9;
    color: white;
    border-color: #4a90d9;
  }
}

.pill-close {
  font-size: 1.1em;
  line-height: 1;
}

.issue-badge {
  display: inline-block;
  padding: 0.2em 0.6em;
  border-radius: 0.25em;
  font-size: 0.85em;
  margin-right: 0.5em;
  color: white;
  font-weight: 500;
}

.issue-level-error {
  background-color: #e53935;
}

.issue-level-warning {
  background-color: #e6a100;
}

.issue-level-info {
  background-color: #43a047;
}

.verbatim-link {
  font-size: 0.85em;
  color: #4a90d9;
}

.count-link {
  color: #4a90d9;
  font-weight: bold;
}
</style>
