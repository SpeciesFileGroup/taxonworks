<template>
  <div class="panel padding-large">
    <h2>Import Timeline</h2>
    <div>
      <div class="timeline-controls">
        <label>
          Select group:
          <select
            v-model="selectedGroup"
            class="margin-small-left"
          >
            <option
              v-for="group in groups"
              :key="group.value"
              :value="group.value"
            >
              {{ group.label }}
            </option>
          </select>
        </label>
      </div>

      <VSpinner v-if="isLoading" />

      <div
        v-else-if="chartData.labels.length > 0"
        :key="selectedGroup"
        class="chart-container margin-medium-top"
      >
        <VueChart
          type="line"
          :data="chartData"
          :options="chartOptions"
        />
      </div>
      <div
        v-else
        class="margin-medium-top"
      >
        No import data available.
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, watch } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VSpinner from '@/components/ui/VSpinner.vue'
import VueChart from '@/components/ui/Chart/index.vue'

const CLB_ISSUE_VOCAB_URL = 'https://api.checklistbank.org/vocab/issue'

const SCALAR_FIELDS = [
  { value: 'taxonCount', label: 'Taxa' },
  { value: 'nameCount', label: 'Names' },
  { value: 'bareNameCount', label: 'Bare names' },
  { value: 'synonymCount', label: 'Synonyms' },
  { value: 'referenceCount', label: 'References' },
  { value: 'distributionCount', label: 'Distributions' },
  { value: 'vernacularCount', label: 'Vernaculars' },
  { value: 'typeMaterialCount', label: 'Type material' },
  { value: 'usagesCount', label: 'Usages' },
  { value: 'mediaCount', label: 'Media' },
  { value: 'treatmentCount', label: 'Treatments' },
  { value: 'estimateCount', label: 'Estimates' },
  { value: 'verbatimCount', label: 'Verbatim' }
]

const MAP_FIELD_LABELS = {
  issuesCount: 'Issues Count',
  namesByRankCount: 'Names By Rank',
  namesByStatusCount: 'Names By Status',
  namesByTypeCount: 'Names By Type',
  namesByCodeCount: 'Names By Code',
  distributionsByGazetteerCount: 'Distributions By Gazetteer',
  extinctTaxaByRankCount: 'Extinct Taxa By Rank',
  synonymsByRankCount: 'Synonyms By Rank',
  taxaByRankCount: 'Taxa By Rank',
  usagesByStatusCount: 'Usages By Status',
  usagesByOriginCount: 'Usages By Origin',
  mediaByTypeCount: 'Media By Type',
  vernacularsByLanguageCount: 'Vernaculars By Language',
  typeMaterialByStatusCount: 'Type Material By Status'
}

// 30 distinct colors for multi-line charts
const LINE_COLORS = [
  '#4a90d9', '#e53935', '#43a047', '#f9a825', '#8e24aa',
  '#00acc1', '#ff7043', '#5c6bc0', '#26a69a', '#d81b60',
  '#7cb342', '#ffa726', '#ab47bc', '#29b6f6', '#ec407a',
  '#66bb6a', '#ef5350', '#42a5f5', '#ffca28', '#78909c',
  '#9ccc65', '#5c85d6', '#c62828', '#2e7d32', '#f57f17',
  '#6a1b9a', '#00838f', '#d84315', '#283593', '#00695c'
]

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
const selectedGroup = ref('default')
const imports = ref([])
const issueVocab = ref([])

const sortedImports = computed(() =>
  [...imports.value].sort(
    (a, b) => new Date(a.started) - new Date(b.started)
  )
)

const dateLabels = computed(() =>
  sortedImports.value.map((i) => {
    const d = new Date(i.started)
    return d.toLocaleDateString('en-US', { month: 'short', year: '2-digit' })
  })
)

// Build issue severity lookup from vocab
// Both the vocab and the import issuesCount keys use lowercase space-separated
// names (e.g. "duplicate name"), so no conversion is needed.
const issueSeverityMap = computed(() => {
  const map = {}
  for (const entry of issueVocab.value) {
    map[entry.name] = entry.level || 'warning'
  }
  return map
})

// Detect available map fields from import data
const availableMapFields = computed(() => {
  if (imports.value.length === 0) return []
  const first = imports.value[0]
  return Object.keys(first).filter(
    (key) =>
      first[key] !== null &&
      typeof first[key] === 'object' &&
      !Array.isArray(first[key]) &&
      MAP_FIELD_LABELS[key]
  )
})

const groups = computed(() => {
  const result = [{ value: 'default', label: 'Default (counts)' }]

  for (const field of availableMapFields.value) {
    if (field === 'issuesCount') {
      result.push(
        { value: 'issuesCount_error', label: 'Issues (Errors)' },
        { value: 'issuesCount_warning', label: 'Issues (Warnings)' },
        { value: 'issuesCount_info', label: 'Issues (Info)' }
      )
    } else {
      result.push({
        value: field,
        label: MAP_FIELD_LABELS[field] || field
      })
    }
  }

  return result
})

// Collect all keys for a given map field across all imports
function collectMapKeys(field) {
  const keys = new Set()
  for (const imp of imports.value) {
    if (imp[field] && typeof imp[field] === 'object') {
      Object.keys(imp[field]).forEach((k) => keys.add(k))
    }
  }
  return [...keys].sort()
}

function titleCase(str) {
  return str
    .replace(/([a-z])([A-Z])/g, '$1 $2')
    .split(' ')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ')
}

const chartData = computed(() => {
  const sorted = sortedImports.value
  const labels = dateLabels.value

  if (sorted.length === 0) return { labels: [], datasets: [] }

  const group = selectedGroup.value

  // Default: scalar fields as separate lines
  if (group === 'default') {
    const datasets = SCALAR_FIELDS.map((field, index) => ({
      label: field.label,
      data: sorted.map((i) => i[field.value] ?? 0),
      borderColor: LINE_COLORS[index % LINE_COLORS.length],
      backgroundColor: LINE_COLORS[index % LINE_COLORS.length],
      fill: false,
      tension: 0.3,
      pointRadius: 2,
      borderWidth: 2
    }))

    return { labels, datasets }
  }

  // Issues split by severity
  if (group.startsWith('issuesCount_')) {
    const severity = group.replace('issuesCount_', '')
    const allKeys = collectMapKeys('issuesCount')
    const filteredKeys = allKeys.filter(
      (k) => (issueSeverityMap.value[k] || 'warning') === severity
    )

    const datasets = filteredKeys.map((key, index) => ({
      label: titleCase(key),
      data: sorted.map((i) => (i.issuesCount && i.issuesCount[key]) || 0),
      borderColor: LINE_COLORS[index % LINE_COLORS.length],
      backgroundColor: LINE_COLORS[index % LINE_COLORS.length],
      fill: false,
      tension: 0.3,
      pointRadius: 2,
      borderWidth: 2
    }))

    return { labels, datasets }
  }

  // Generic map field
  const allKeys = collectMapKeys(group)
  const datasets = allKeys.map((key, index) => ({
    label: titleCase(key),
    data: sorted.map((i) => (i[group] && i[group][key]) || 0),
    borderColor: LINE_COLORS[index % LINE_COLORS.length],
    backgroundColor: LINE_COLORS[index % LINE_COLORS.length],
    fill: false,
    tension: 0.3,
    pointRadius: 2,
    borderWidth: 2
  }))

  return { labels, datasets }
})

const chartOptions = computed(() => ({
  responsive: true,
  maintainAspectRatio: false,
  interaction: {
    mode: 'nearest',
    intersect: false
  },
  plugins: {
    legend: {
      position: 'right',
      labels: {
        usePointStyle: true,
        pointStyle: 'circle',
        padding: 12,
        font: { size: 11 }
      }
    },
    tooltip: {
      callbacks: {
        title(context) {
          const idx = context[0].dataIndex
          const imp = sortedImports.value[idx]
          if (!imp) return ''
          return new Date(imp.started).toLocaleString('en-US', {
            weekday: 'long',
            month: 'short',
            day: 'numeric',
            hour: '2-digit',
            minute: '2-digit'
          })
        },
        label(context) {
          const label = context.dataset.label || ''
          const value = (context.parsed.y ?? 0).toLocaleString()
          return ` ${label}: ${value}`
        }
      }
    }
  },
  scales: {
    x: {
      title: { display: true, text: 'Date' }
    },
    y: {
      beginAtZero: true,
      title: { display: true, text: 'Count' }
    }
  }
}))

onMounted(() => {
  loadImports()
  loadVocab()
})

watch(() => props.datasetId, loadImports)

async function loadVocab() {
  try {
    const response = await fetch(CLB_ISSUE_VOCAB_URL)
    issueVocab.value = await response.json()
  } catch {
    issueVocab.value = []
  }
}

async function loadImports() {
  isLoading.value = true
  try {
    const { body } = await ColdpExportPreference.checklistbankImports(
      props.projectId,
      { checklistbank_dataset_id: props.datasetId }
    )
    imports.value = Array.isArray(body) ? body : (body.result || [])
  } catch {
    imports.value = []
  } finally {
    isLoading.value = false
  }
}
</script>

<style lang="scss" scoped>
.timeline-controls {
  display: flex;
  align-items: center;
}

.chart-container {
  position: relative;
  width: 100%;
  height: 400px;
}
</style>
