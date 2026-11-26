<template>
  <div class="panel content input-panel">
    <h3>Provide citations</h3>
    <p class="subtle">
      Paste verbatim citations (one per line), paste spreadsheet columns
      including a header row, or drag &amp; drop a CSV/TSV file or a file of
      citations, one per line. Maximum {{ MAX_ROWS.toLocaleString() }} rows.
    </p>

    <SampleTable
      class="margin-medium-bottom"
      :groups="SAMPLE_GROUPS"
      :rows="SAMPLE_ROWS"
      :help="FIELD_HELP"
    >
      <p class="subtle">
        Columns are found by these names (case, spaces, and punctuation don't
        matter); other columns are ignored. Give a full citation, its parts,
        or both; a part in its own column is used instead of the one found
        in the full citation.
      </p>
    </SampleTable>

    <TextFileDropArea
      v-model:text="text"
      v-model:file-name="fileName"
      placeholder="Paste citations here, one per line, or drag a CSV file..."
      autofocus
    />

    <p
      v-if="table && recognizedColumns.length"
      class="subtle margin-small-top"
    >
      {{ fileName ? `From ${fileName}: using` : 'Using' }}
      <b>{{ Object.keys(recognizedColumns.byHeader).join(', ') }}</b>{{
        ignoredHeaders.length ? `; ignoring ${ignoredHeaders.join(', ')}` : ''
      }}.
    </p>
    <div
      v-else-if="table"
      class="feedback feedback-warning feedback-thin margin-small-top"
    >
      The first line was read as column names ({{
        table.headers.map(truncate).join(', ')
      }}), but none of them is one of the names above. For a table, name its
      columns in the first line; for one citation per line, make the first
      line <b>verbatim</b>.
    </div>
    <p
      v-else-if="isLinesFile"
      class="subtle margin-small-top"
    >
      {{ fileName }} has no column names in its first line, so each line is
      read as a citation.
    </p>

    <div
      v-if="rawRowCount > MAX_ROWS"
      class="feedback feedback-warning feedback-thin margin-small-top"
    >
      More than {{ MAX_ROWS.toLocaleString() }} rows provided; only the first
      {{ MAX_ROWS.toLocaleString() }} will be processed.
    </div>

    <div class="flex-row flex-separate middle margin-small-top">
      <span class="subtle">{{ rowCount }} {{ pluralize(rowCount, 'row') }}</span>
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
import { ref, computed } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import SampleTable from '@/components/BatchLoad/SampleTable.vue'
import TextFileDropArea from '@/components/BatchLoad/TextFileDropArea.vue'
import { parseDelimited } from '@/helpers/parseDelimited.js'
import { pluralize } from '@/helpers/strings.js'
import { FIELD, FIELD_HELP, MAX_ROWS } from '../constants.js'

const emit = defineEmits(['submit'])

const SAMPLE_GROUPS = [
  { label: 'a full citation', fields: [FIELD.VERBATIM] },
  {
    label: 'and/or its parts',
    fields: Object.values(FIELD).filter((f) => f !== FIELD.VERBATIM)
  }
]

const SAMPLE_ROWS = [
  {
    [FIELD.VERBATIM]:
      'Ritzi, C.M. & Whitaker, J.O., Jr. (2003) Ectoparasites of small mammals from the Newport Chemical Depot, Vermillion County, Indiana. Northeastern Naturalist, 10(2), 149-158.'
  },
  {
    [FIELD.AUTHORS]: 'Ritzi, C.M. & J.O. Whitaker, Jr.',
    [FIELD.YEAR]: '2003',
    [FIELD.JOURNAL]: 'Northeastern Naturalist',
    [FIELD.VOLUME]: '10(2)',
    [FIELD.PAGES]: '149-158'
  }
]

const FIELDS = new Set(Object.values(FIELD))

const text = ref('')
const fileName = ref(null)

// A first line of just `verbatim` heads one citation per line. Otherwise
// tab separated text (a spreadsheet paste) is a table with a header row, as
// is a loaded file whose first line has a recognized column name; anything
// else is one verbatim citation per line.
const hasVerbatimHeader = computed(() => {
  const firstLine = text.value.trimStart().split(/\r?\n/, 1)[0]
  return (
    !firstLine.includes('\t') && normalizeHeader(firstLine) === FIELD.VERBATIM
  )
})

const parsedTable = computed(() => {
  if (hasVerbatimHeader.value) return null

  if (fileName.value || isTabular(text.value)) {
    // Blank rows are kept, so that copied columns line up with the input.
    const parsed = parseDelimited(text.value, { keepBlankRows: true })
    return parsed.headers.length ? parsed : null
  }
  return null
})

// { byHeader: { header: field }, length }; when two headers name the same
// field the first one is used.
const recognizedColumns = computed(() => {
  const byHeader = {}
  const used = new Set()

  ;(parsedTable.value?.headers || []).forEach((header) => {
    const field = normalizeHeader(header)
    if (FIELDS.has(field) && !used.has(field)) {
      byHeader[header] = field
      used.add(field)
    }
  })

  return { byHeader, length: used.size }
})

// A loaded file of citations without a header row: the parser reads its
// first citation as comma separated "headers", none of them recognized. A
// year in that first line tells it from a header row of unknown names.
const isLinesFile = computed(
  () =>
    !!parsedTable.value &&
    !isTabular(text.value) &&
    recognizedColumns.value.length === 0 &&
    // A year, with or without a suffix (1900, 1900b)
    /\b(1[5-9]|20)\d{2}(?!\d)/.test(text.value.trimStart().split(/\r?\n/, 1)[0])
)

const table = computed(() => (isLinesFile.value ? null : parsedTable.value))

const ignoredHeaders = computed(() =>
  (table.value?.headers || []).filter(
    (h) => !(h in recognizedColumns.value.byHeader)
  )
)

// Blank lines between citations are kept (as empty rows), so that copied
// columns line up with the input; trailing ones, and those before a
// `verbatim` header, aren't.
const verbatimLines = computed(() => {
  const lines = text.value.split(/\r?\n/).map((l) => unquote(l.trim()))
  while (lines.length && !lines.at(-1)) lines.pop()
  if (hasVerbatimHeader.value) {
    return lines.slice(lines.findIndex(Boolean) + 1)
  }
  return lines
})

const rawRowCount = computed(() =>
  table.value ? table.value.rows.length : verbatimLines.value.length
)

const rowCount = computed(() => Math.min(rawRowCount.value, MAX_ROWS))

const canSubmit = computed(
  () =>
    rowCount.value > 0 && (!table.value || recognizedColumns.value.length > 0)
)

function truncate(value) {
  return value.length > 30 ? `${value.slice(0, 30)}…` : value
}

function normalizeHeader(header) {
  return header.toLowerCase().replace(/[^a-z]/g, '')
}

// A spreadsheet saves a one-column CSV with quotes around values that have
// commas: `"Smith, J. (1990) ..."`.
function unquote(line) {
  const m = line.match(/^"(.*)"$/)
  return m ? m[1].replaceAll('""', '"') : line
}

function isTabular(value) {
  return (value.split(/\r?\n/).find((l) => l.trim()) || '').includes('\t')
}

function submit() {
  let rows

  if (table.value) {
    const fieldByHeader = Object.entries(recognizedColumns.value.byHeader)

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

  emit('submit', { rows })
}
</script>

<style scoped>
.input-panel {
  max-width: 1000px;
}
</style>
