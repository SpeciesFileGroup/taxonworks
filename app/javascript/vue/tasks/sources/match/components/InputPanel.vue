<template>
  <div class="panel content input-panel">
    <h3>Provide citations</h3>
    <p class="subtle">
      Paste verbatim citations (one per line), paste spreadsheet columns
      including a header row, or drag &amp; drop a CSV/TSV file. Maximum
      {{ MAX_ROWS.toLocaleString() }} rows.
    </p>

    <TextFileDropArea
      v-model:text="text"
      v-model:file-name="fileName"
      placeholder="Paste citations here, one per line, or drag a CSV file..."
      autofocus
    />

    <div
      v-if="table"
      class="margin-medium-top"
    >
      <h3>Columns</h3>
      <p class="subtle">
        Choose what each column holds. Structured columns are compared field
        by field; a verbatim column is split into authors, year, and the rest
        where possible.
        <span v-if="fileName">Loaded from {{ fileName }}.</span>
      </p>
      <table class="table-striped column-mapping">
        <thead>
          <tr>
            <th>Column</th>
            <th>Holds</th>
            <th>First value</th>
          </tr>
        </thead>
        <tbody>
          <tr
            v-for="header in table.headers"
            :key="header"
          >
            <td>{{ header }}</td>
            <td>
              <select
                class="normal-input"
                v-model="mapping[header]"
              >
                <option value="">(ignore)</option>
                <option
                  v-for="field in Object.values(FIELD)"
                  :key="field"
                  :value="field"
                  :disabled="isMappedElsewhere(field, header)"
                >
                  {{ FIELD_LABELS[field] }}
                </option>
              </select>
            </td>
            <td class="subtle">{{ table.rows[0]?.[header] }}</td>
          </tr>
        </tbody>
      </table>
    </div>

    <div
      v-if="rawRowCount > MAX_ROWS"
      class="feedback feedback-warning feedback-thin margin-small-top"
    >
      More than {{ MAX_ROWS.toLocaleString() }} rows provided; only the first
      {{ MAX_ROWS.toLocaleString() }} will be processed.
    </div>

    <div class="flex-row flex-separate middle margin-small-top">
      <span class="subtle">{{ rowCount }} row(s)</span>
      <VBtn
        color="primary"
        medium
        :disabled="!canSubmit"
        @click="submit"
      >
        Process
      </VBtn>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, watch } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import TextFileDropArea from '@/components/BatchLoad/TextFileDropArea.vue'
import { parseDelimited } from '@/helpers/parseDelimited.js'
import { FIELD, FIELD_LABELS, HEADER_ALIASES, MAX_ROWS } from '../constants.js'

const emit = defineEmits(['submit'])

const text = ref('')
const fileName = ref(null)
const mapping = ref({})

// Tab separated text (a spreadsheet paste) or a loaded file is a table with
// a header row; anything else is one verbatim citation per line.
const table = computed(() => {
  if (fileName.value || isTabular(text.value)) {
    const parsed = parseDelimited(text.value)
    return parsed.headers.length ? parsed : null
  }
  return null
})

const verbatimLines = computed(() =>
  text.value
    .split(/\r?\n/)
    .map((l) => l.trim())
    .filter(Boolean)
)

const rawRowCount = computed(() =>
  table.value ? table.value.rows.length : verbatimLines.value.length
)

const rowCount = computed(() => Math.min(rawRowCount.value, MAX_ROWS))

const canSubmit = computed(
  () =>
    rowCount.value > 0 &&
    (!table.value || Object.values(mapping.value).some(Boolean))
)

watch(
  () => table.value?.headers,
  (headers) => {
    const next = {}
    const used = new Set()

    ;(headers || []).forEach((header) => {
      const guess = HEADER_ALIASES[header.toLowerCase().replace(/[^a-z]/g, '')]
      next[header] = guess && !used.has(guess) ? guess : ''
      if (guess) used.add(guess)
    })

    mapping.value = next
  }
)

function isTabular(value) {
  return (value.split(/\r?\n/, 1)[0] || '').includes('\t')
}

function isMappedElsewhere(field, header) {
  return Object.entries(mapping.value).some(
    ([h, f]) => f === field && h !== header
  )
}

function submit() {
  let rows

  if (table.value) {
    const fieldByHeader = Object.entries(mapping.value).filter(([, f]) => f)

    rows = table.value.rows.slice(0, MAX_ROWS).map((csvRow) => {
      const input = {}
      fieldByHeader.forEach(([header, field]) => {
        if (csvRow[header]) input[field] = csvRow[header]
      })
      return { input, csvRow }
    })
  } else {
    rows = verbatimLines.value
      .slice(0, MAX_ROWS)
      .map((line) => ({ input: { [FIELD.VERBATIM]: line }, csvRow: null }))
  }

  emit('submit', {
    rows,
    headers: table.value ? table.value.headers : null
  })
}
</script>

<style scoped>
.input-panel {
  max-width: 1000px;
}
</style>
