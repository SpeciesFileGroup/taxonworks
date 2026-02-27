<template>
  <div
    class="panel padding-large"
    :style="isLoadingImports ? { minHeight: '300px', position: 'relative' } : {}"
  >
    <h2>Import Diff</h2>

    <VSpinner v-if="isLoadingImports" />

    <div
      v-else-if="finishedImports.length < 2"
      class="margin-medium-top"
    >
      <p>At least two finished imports are required to compare.</p>
    </div>

    <template v-else>
      <div class="diff-controls">
        <label>
          Attempt 1 (older):
          <select
            v-model="selectedAttempt1"
            class="margin-small-left"
          >
            <option
              v-for="imp in finishedImports"
              :key="imp.attempt"
              :value="imp.attempt"
            >
              #{{ imp.attempt }} — {{ formatDate(imp.started) }}
            </option>
          </select>
        </label>

        <label class="margin-medium-left">
          Attempt 2 (newer):
          <select
            v-model="selectedAttempt2"
            class="margin-small-left"
          >
            <option
              v-for="imp in finishedImports"
              :key="imp.attempt"
              :value="imp.attempt"
            >
              #{{ imp.attempt }} — {{ formatDate(imp.started) }}
            </option>
          </select>
        </label>

        <VBtn
          color="primary"
          class="margin-medium-left"
          :disabled="!canCompare || isLoading"
          @click="fetchDiff"
        >
          Compare
        </VBtn>
      </div>

      <p
        v-if="validationError"
        class="diff-validation-error margin-small-top"
      >
        {{ validationError }}
      </p>

      <VSpinner v-if="isLoading" />

      <div
        v-else-if="errorMessage"
        class="margin-medium-top"
      >
        <p class="diff-error">{{ errorMessage }}</p>
      </div>

      <div
        v-else-if="diffFetched && parsedLines.length === 0"
        class="margin-medium-top"
      >
        <p>No changes between these attempts.</p>
      </div>

      <div
        v-else-if="parsedLines.length > 0"
        class="diff-table-wrapper margin-medium-top"
      >
        <table class="diff-table">
          <thead>
            <tr>
              <th class="diff-line-num">#</th>
              <th class="diff-content-col">Removed</th>
              <th class="diff-line-num">#</th>
              <th class="diff-content-col">Added</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="(row, index) in sideBySideRows"
              :key="index"
            >
              <td class="diff-line-num">{{ row.leftNum }}</td>
              <td :class="['diff-cell', row.leftClass]">{{ row.leftText }}</td>
              <td class="diff-line-num">{{ row.rightNum }}</td>
              <td :class="['diff-cell', row.rightClass]">{{ row.rightText }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted } from 'vue'
import { ColdpExportPreference } from '@/routes/endpoints'
import VBtn from '@/components/ui/VBtn/index.vue'
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
const isLoadingImports = ref(false)
const rawDiff = ref('')
const diffFetched = ref(false)
const errorMessage = ref('')
const selectedAttempt1 = ref(null)
const selectedAttempt2 = ref(null)
const importRecords = ref([])

const finishedImports = computed(() =>
  [...importRecords.value]
    .filter((i) => i.attempt != null)
    .sort((a, b) => b.attempt - a.attempt)
)

onMounted(loadImports)
watch(() => props.datasetId, loadImports)

async function loadImports() {
  isLoadingImports.value = true
  try {
    const { body } = await ColdpExportPreference.checklistbankImports(
      props.projectId,
      { checklistbank_dataset_id: props.datasetId }
    )
    importRecords.value = Array.isArray(body) ? body : (body.result || [])
  } catch {
    importRecords.value = []
  } finally {
    isLoadingImports.value = false
  }
}

// Auto-select the two most recent attempts when imports change
watch(
  finishedImports,
  (val) => {
    if (val.length >= 2 && selectedAttempt1.value === null) {
      selectedAttempt1.value = val[1].attempt
      selectedAttempt2.value = val[0].attempt
    }
  },
  { immediate: true }
)

const validationError = computed(() => {
  if (
    selectedAttempt1.value !== null &&
    selectedAttempt2.value !== null &&
    selectedAttempt1.value >= selectedAttempt2.value
  ) {
    return 'Attempt 1 must be older (lower number) than Attempt 2.'
  }
  return ''
})

const canCompare = computed(
  () =>
    selectedAttempt1.value !== null &&
    selectedAttempt2.value !== null &&
    selectedAttempt1.value < selectedAttempt2.value
)

const parsedLines = computed(() => parseUnifiedDiff(rawDiff.value))

const sideBySideRows = computed(() => {
  const rows = []
  for (const line of parsedLines.value) {
    if (line.type === 'hunk') {
      rows.push({
        leftNum: '...',
        leftText: line.text,
        leftClass: 'diff-hunk',
        rightNum: '...',
        rightText: line.text,
        rightClass: 'diff-hunk'
      })
    } else if (line.type === 'context') {
      rows.push({
        leftNum: line.leftLine,
        leftText: line.text,
        leftClass: '',
        rightNum: line.rightLine,
        rightText: line.text,
        rightClass: ''
      })
    } else if (line.type === 'delete') {
      rows.push({
        leftNum: line.leftLine,
        leftText: line.text,
        leftClass: 'diff-delete',
        rightNum: '',
        rightText: '',
        rightClass: 'diff-empty'
      })
    } else if (line.type === 'insert') {
      rows.push({
        leftNum: '',
        leftText: '',
        leftClass: 'diff-empty',
        rightNum: line.rightLine,
        rightText: line.text,
        rightClass: 'diff-insert'
      })
    }
  }
  return rows
})

function parseUnifiedDiff(text) {
  if (!text || !text.trim()) return []

  const lines = text.split(/\r?\n/)
  const result = []
  let leftLine = 0
  let rightLine = 0

  for (const raw of lines) {
    // Skip file headers
    if (raw.startsWith('---') || raw.startsWith('+++')) continue

    // Hunk header: @@ -oldStart,oldLen +newStart,newLen @@
    const hunkMatch = raw.match(/^@@\s+-(\d+)(?:,\d+)?\s+\+(\d+)(?:,\d+)?\s+@@/)
    if (hunkMatch) {
      leftLine = parseInt(hunkMatch[1], 10)
      rightLine = parseInt(hunkMatch[2], 10)
      result.push({ type: 'hunk', text: raw })
      continue
    }

    if (raw.startsWith('-')) {
      const content = raw.substring(1)
      if (content.trim() === '') { leftLine++; continue }
      result.push({ type: 'delete', text: content, leftLine })
      leftLine++
    } else if (raw.startsWith('+')) {
      const content = raw.substring(1)
      if (content.trim() === '') { rightLine++; continue }
      result.push({ type: 'insert', text: content, rightLine })
      rightLine++
    } else if (raw.startsWith(' ')) {
      const content = raw.substring(1)
      if (content.trim() === '') { leftLine++; rightLine++; continue }
      result.push({
        type: 'context',
        text: content,
        leftLine,
        rightLine
      })
      leftLine++
      rightLine++
    } else if (raw.trim() === '') {
      // Skip blank lines (avoids extra vertical spacing)
      continue
    } else {
      // Non-empty unrecognized lines treated as context
      result.push({
        type: 'context',
        text: raw,
        leftLine,
        rightLine
      })
      leftLine++
      rightLine++
    }
  }

  return result
}

function formatDate(dateString) {
  if (!dateString) return ''
  const d = new Date(dateString)
  return d.toLocaleDateString('en-US', {
    month: 'short',
    day: 'numeric',
    year: 'numeric'
  })
}

async function fetchDiff() {
  isLoading.value = true
  errorMessage.value = ''
  rawDiff.value = ''
  diffFetched.value = false

  try {
    const { body } = await ColdpExportPreference.checklistbankDiff(
      props.projectId,
      {
        checklistbank_dataset_id: props.datasetId,
        attempt1: selectedAttempt1.value,
        attempt2: selectedAttempt2.value
      }
    )

    if (body.error) {
      errorMessage.value = body.error
    } else {
      rawDiff.value = body.diff || ''
      diffFetched.value = true
    }
  } catch {
    errorMessage.value = 'Diff not available for these attempts.'
  } finally {
    isLoading.value = false
  }
}
</script>

<style lang="scss" scoped>
.diff-controls {
  display: flex;
  align-items: center;
  flex-wrap: wrap;
  gap: 0.5em;
}

.diff-validation-error {
  color: #e53935;
  font-size: 0.9em;
}

.diff-error {
  color: #e53935;
}

.diff-table-wrapper {
  overflow-x: auto;
  max-height: 600px;
  overflow-y: auto;
  border: 1px solid var(--border-color, #ddd);
  border-radius: 4px;
}

.diff-table {
  width: 100%;
  border-collapse: collapse;
  font-family: monospace;
  font-size: 0.85em;
  line-height: 1.2;
  background-color: var(--bg-foreground, #ffffff);

  th, td {
    padding: 0 0.3em !important;
    line-height: 1 !important;
    vertical-align: middle;
  }

  thead th {
    position: sticky;
    top: 0;
    background: var(--bg-muted, #f5f5f5);
    color: var(--text-color, #1a1a1a);
    border-bottom: 2px solid var(--border-color, #ddd);
    text-align: left;
    font-weight: 600;
    vertical-align: middle;
    padding: 0.3em;
  }
}

.diff-line-num {
  width: 3em;
  min-width: 3em;
  color: #999;
  text-align: right;
  user-select: none;
  border-right: 1px solid var(--border-color, #eee);
}

.diff-content-col {
  width: 50%;
}

.diff-cell {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.diff-delete {
  background-color: #fdd;
  color: #6e1212;
}

.diff-insert {
  background-color: #dfd;
  color: #125e12;
}

.diff-hunk {
  background-color: var(--bg-muted, #f0f0ff);
  color: #888;
  font-style: italic;
}

.diff-empty {
  background-color: #f9f9f9;
}
</style>

<style lang="scss">
.dark .diff-delete {
  background-color: #3c1616;
  color: #f5aaaa;
}

.dark .diff-insert {
  background-color: #163c16;
  color: #a8f0a8;
}

.dark .diff-empty {
  background-color: #2a2a2a;
}
</style>
