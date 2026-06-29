<template>
  <div class="panel content">
    <h3>Provide names</h3>
    <p class="subtle">
      Paste names (one per line) or drag &amp; drop a CSV file with a
      <code>scientificName</code> column. Maximum 3,000 rows.
    </p>

    <div
      class="dropzone-area"
      :class="{ 'dropzone-active': isDragging }"
      @dragover.prevent="isDragging = true"
      @dragleave.prevent="isDragging = false"
      @drop.prevent="handleFileDrop"
    >
      <textarea
        v-model="nameText"
        class="full_width"
        placeholder="Paste names here, one per line, or drag a CSV file..."
        rows="12"
      />
    </div>

    <div
      v-if="rawNonEmptyCount > MAX_ROWS"
      class="truncation-warning margin-small-top"
    >
      More than {{ MAX_ROWS.toLocaleString() }} rows provided; only the first {{ MAX_ROWS.toLocaleString() }} will be processed.
    </div>

    <div class="flex-row flex-separate margin-small-top">
      <span class="subtle"
        >{{ nonEmptyCount }} name(s), {{ lineCount }} total row(s)</span
      >
      <VBtn
        color="primary"
        medium
        :disabled="!nonEmptyCount"
        @click="submit"
      >
        Process
      </VBtn>
    </div>

    <div
      v-if="fileInfo"
      class="margin-small-top"
    >
      <span class="subtle">
        Loaded from: {{ fileInfo.name }} ({{ fileInfo.rowCount }} rows)
      </span>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import { useDropzonePasteManager } from '@/composables/useDropzonePasteManager'
import { MAX_ROWS } from '../constants.js'

const emit = defineEmits(['submit'])

const { registerPaster, unregisterPaster } = useDropzonePasteManager()

const nameText = ref('')
const isDragging = ref(false)
const csvParsedData = ref(null)
const fileInfo = ref(null)
let pasteZone = null

const lines = computed(() => nameText.value.split('\n').map((l) => l.trim()))

const rawNonEmptyCount = computed(() => lines.value.filter(Boolean).length)

const nonEmptyCount = computed(() => Math.min(rawNonEmptyCount.value, MAX_ROWS))

const lineCount = computed(() => nameText.value.trim() ? Math.min(lines.value.length, MAX_ROWS) : 0)

function submit() {
  emit('submit', {
    names: lines.value.slice(0, MAX_ROWS),
    csv: csvParsedData.value
  })
}

function loadFile(file) {
  const reader = new FileReader()
  reader.onload = (e) => parseCSV(e.target.result, file.name)
  reader.readAsText(file)
}

function handleFileDrop(event) {
  isDragging.value = false
  const file = event.dataTransfer?.files?.[0]
  if (!file) return
  loadFile(file)
}

function handleFilePaste(event) {
  const items = event.clipboardData?.items
  if (!items) return

  for (const item of items) {
    if (item.kind !== 'file') continue
    const file = item.getAsFile()
    if (!file) continue
    event.preventDefault()
    loadFile(file)
    return
  }
}

onMounted(() => {
  pasteZone = { handler: handleFilePaste, prioritize: false }
  registerPaster(pasteZone)
})

onBeforeUnmount(() => {
  unregisterPaster(pasteZone)
})

function parseCSV(text, fileName) {
  const lines = text.split(/\r?\n/).filter((l) => l.trim())
  if (lines.length < 2) {
    TW.workbench.alert.create('CSV file appears empty or has no data rows.', 'error')
    return
  }

  const headerLine = lines[0]
  const delimiter = headerLine.includes('\t') ? '\t' : ','
  const headers = parseCsvLine(headerLine, delimiter).map((h) => h.trim())

  const scientificNameIndex = headers.findIndex(
    (h) => h.toLowerCase() === 'scientificname'
  )

  if (scientificNameIndex < 0) {
    TW.workbench.alert.create('CSV must have a "scientificName" column.', 'error')
    return
  }

  const dataLines = lines.slice(1)
  const names = []
  const csvRows = []

  // One over MAX_ROWS so nonEmptyCount exceeds MAX_ROWS and the truncation warning fires.
  dataLines.slice(0, MAX_ROWS + 1).forEach((line) => {
    const fields = parseCsvLine(line, delimiter)
    const name = fields[scientificNameIndex]?.trim()

    if (name) {
      names.push(name)
      const rowData = {}
      headers.forEach((header, i) => {
        rowData[header] = fields[i]?.trim() || ''
      })
      csvRows.push(rowData)
    }
  })

  csvParsedData.value = {
    headers,
    rows: csvRows
  }

  fileInfo.value = {
    name: fileName,
    rowCount: Math.min(names.length, MAX_ROWS)
  }

  nameText.value = names.join('\n')
}

function parseCsvLine(line, delimiter) {
  const fields = []
  let current = ''
  let inQuotes = false

  for (let i = 0; i < line.length; i++) {
    const char = line[i]

    if (inQuotes) {
      if (char === '"') {
        if (i + 1 < line.length && line[i + 1] === '"') {
          current += '"'
          i++
        } else {
          inQuotes = false
        }
      } else {
        current += char
      }
    } else {
      if (char === '"') {
        inQuotes = true
      } else if (char === delimiter) {
        fields.push(current)
        current = ''
      } else {
        current += char
      }
    }
  }

  fields.push(current)
  return fields
}
</script>

<style scoped>
.dropzone-area {
  border: 2px dashed #ccc;
  border-radius: 4px;
  transition: border-color 0.2s;
}

.dropzone-active {
  border-color: #5bc0de;
  background-color: #f0f9ff;
}

.dropzone-area textarea {
  border: none;
}

.subtle {
  color: #888;
  font-size: 0.85em;
}

.truncation-warning {
  color: #8a6d3b;
  background-color: #fcf8e3;
  border: 1px solid #faebcc;
  border-radius: 4px;
  padding: 6px 10px;
  font-size: 0.85em;
}
</style>
