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

        <div class="issue-import-controls margin-medium-bottom">
          <VBtn
            color="create"
            :disabled="isImporting || checkedIssueKeys.length === 0"
            @click="importSelectedIssues"
          >
            Import {{ checkedIssueKeys.length }} selected issue{{ checkedIssueKeys.length === 1 ? '' : 's' }} as tags
          </VBtn>
          <span class="margin-small-left margin-small-right">
            Select:
            <a
              href="#"
              @click.prevent="selectAllFiltered"
            >all</a> ·
            <a
              href="#"
              @click.prevent="selectNone"
            >none</a> ·
            <a
              href="#"
              @click.prevent="selectByLevel('error')"
            >errors</a> ·
            <a
              href="#"
              @click.prevent="selectByLevel('warning')"
            >warnings</a>
          </span>
          <VSpinner
            v-if="isImporting"
            :logo-size="{ width: '20px', height: '20px' }"
          />
        </div>

        <table class="vue-table">
          <thead>
            <tr>
              <th class="checkbox-col">
                <input
                  type="checkbox"
                  :checked="allFilteredChecked"
                  :indeterminate="someFilteredChecked && !allFilteredChecked"
                  @change="toggleAllFiltered"
                >
              </th>
              <th>Title</th>
              <th>Count</th>
              <th>TW Filter</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="issue in filteredIssues"
              :key="issue.key"
            >
              <td class="checkbox-col">
                <input
                  type="checkbox"
                  :checked="checkedIssues.has(issue.key)"
                  @change="toggleIssueCheck(issue.key)"
                >
              </td>
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
              <td>
                <a
                  v-if="twFilterLink(issue)"
                  :href="twFilterLink(issue).url"
                  class="tw-filter-link"
                >{{ twFilterLink(issue).tagCount }} tagged</a>
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
import VBtn from '@/components/ui/VBtn/index.vue'

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
const isImporting = ref(false)
const issuesData = ref({})
const issueVocab = ref([])
const selectedGroups = ref(new Set())
const issueKeywords = ref([])
const checkedIssues = ref(new Set())

onMounted(() => {
  loadIssues()
  loadVocab()
  loadIssueKeywords()
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

// --- Checkbox logic ---

const checkedIssueKeys = computed(() => [...checkedIssues.value])

const allFilteredChecked = computed(() =>
  filteredIssues.value.length > 0 &&
  filteredIssues.value.every((i) => checkedIssues.value.has(i.key))
)

const someFilteredChecked = computed(() =>
  filteredIssues.value.some((i) => checkedIssues.value.has(i.key))
)

function toggleIssueCheck(key) {
  const next = new Set(checkedIssues.value)
  if (next.has(key)) {
    next.delete(key)
  } else {
    next.add(key)
  }
  checkedIssues.value = next
}

function toggleAllFiltered() {
  if (allFilteredChecked.value) {
    selectNone()
  } else {
    selectAllFiltered()
  }
}

function selectAllFiltered() {
  const next = new Set(checkedIssues.value)
  filteredIssues.value.forEach((i) => next.add(i.key))
  checkedIssues.value = next
}

function selectNone() {
  checkedIssues.value = new Set()
}

function selectByLevel(level) {
  const next = new Set()
  sortedIssues.value
    .filter((i) => i.level === level)
    .forEach((i) => next.add(i.key))
  checkedIssues.value = next
}

// --- Import ---

async function importSelectedIssues() {
  const keys = checkedIssueKeys.value
  if (keys.length === 0) return

  if (!confirm(`Import ${keys.length} issue type${keys.length === 1 ? '' : 's'} as tags? This runs as a background job.`)) return

  isImporting.value = true
  try {
    await ColdpExportPreference.bulkLoadIssueTags(props.projectId, {
      checklistbank_dataset_id: props.datasetId,
      issue_keys: keys
    })
    TW.workbench.alert.create('Issue tag import job enqueued. TW filter links will appear after the job completes and you refresh the page.', 'notice')
  } catch {
    TW.workbench.alert.create('Failed to enqueue job', 'error')
  } finally {
    isImporting.value = false
  }
}

// --- TW Filter links ---

async function loadIssueKeywords() {
  try {
    const { body } = await ColdpExportPreference.coldpIssueKeywords(props.projectId)
    issueKeywords.value = body || []
  } catch {
    issueKeywords.value = []
  }
}

const GROUP_FILTER_PATHS = {
  'name': '/tasks/taxon_names/filter',
  'synonym': '/tasks/taxon_names/filter',
  'name usage': '/tasks/otus/filter',
  'distribution': '/tasks/asserted_distributions/filter',
  'reference': '/tasks/sources/filter',
  'species interaction': '/tasks/biological_associations/filter',
  'vernacular': '/tasks/otus/filter'
}

function twFilterLink(issue) {
  const keywordName = `COLDP: ${issue.title}`
  const keyword = issueKeywords.value.find((k) => k.name === keywordName)
  if (!keyword || keyword.tag_count === 0) return null

  const path = GROUP_FILTER_PATHS[issue.group] || '/tasks/otus/filter'
  return {
    url: `${path}?keyword_id_or[]=${keyword.id}`,
    tagCount: keyword.tag_count
  }
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

.tw-filter-link {
  color: #43a047;
  font-weight: 500;
  font-size: 0.9em;
}

.checkbox-col {
  width: 2em;
  text-align: center;
}

.issue-import-controls {
  display: flex;
  align-items: center;
  gap: 0.5em;

  a {
    color: #4a90d9;
    text-decoration: none;
    font-size: 0.9em;

    &:hover {
      text-decoration: underline;
    }
  }
}
</style>
