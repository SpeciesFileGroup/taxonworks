<template>
  <table class="table-striped full_width result-table">
    <thead>
      <tr>
        <th>#</th>
        <th
          data-help="The row as given. Below it, what was read from it: the authors' surnames, year, volume, first page, and DOI that are compared to each candidate. A wrong reading there explains a wrong match."
        >
          Row
        </th>
        <th>
          <div class="horizontal-left-content middle gap-small">
            <span>Status</span>
            <ButtonClipboard
              :text="columnTexts.status"
              title="Copy the status column: every row, in input order"
            />
            <select
              class="normal-input"
              :value="filter"
              title="Which rows to show"
              @change="emit('update:filter', $event.target.value)"
            >
              <option
                v-for="value in Object.values(ROW_FILTER)"
                :key="value"
                :value="value"
              >
                {{ ROW_FILTER_LABELS[value] }}
              </option>
            </select>
          </div>
        </th>
        <th
          data-help="The matched (or, when ambiguous, best) Source. Chips compare it to the row: green agrees, yellow differs but is not required to agree, red fails a requirement. Hover a chip for details."
        >
          <div class="horizontal-left-content middle gap-small">
            <span>Source</span>
            <ButtonClipboard
              :text="columnTexts.source"
              title="Copy the Source column: every row, in input order; empty unless matched or selected"
            />
          </div>
        </th>
        <th
          data-help="How many of the Sources found for the row pass every requirement - the ones listed at the bottom of Match options, which change with the options. Open a row to compare them and pick one."
        >
          <div class="horizontal-left-content middle gap-small">
            <span>Candidates</span>
            <VBtn
              color="primary"
              medium
              title="Open the candidates of every row on this page"
              @click="expandAll"
            >
              Open all
            </VBtn>
            <VBtn
              color="primary"
              medium
              title="Close the candidates of every row"
              @click="expanded = new Set()"
            >
              Close all
            </VBtn>
          </div>
        </th>
        <th
          data-help="Search for and select a Source, overriding the automatic match."
        >
          Refine
        </th>
        <th>
          <div class="horizontal-left-content middle gap-small">
            <span>Source id</span>
            <ButtonClipboard
              :text="columnTexts.sourceId"
              title="Copy the Source id column: every row, in input order; empty unless matched or selected"
            />
          </div>
        </th>
      </tr>
    </thead>
    <tbody>
      <template
        v-for="row in rows"
        :key="row.index"
      >
        <tr :class="`row-${evaluations[row.index].status}`">
          <td>{{ row.index + 1 }}</td>

          <td class="input-cell">
            <span
              v-if="row.isEmpty"
              class="subtle"
              >EMPTY</span
            >
            <template v-else>
              <div>{{ inputSummary(row.input) }}</div>
              <div class="subtle">
                {{ parsedSummary(row.parsed) }}
              </div>
            </template>
          </td>

          <td>
            <div class="horizontal-left-content gap-small">
              <VBadge
                class="line-nowrap"
                :color="STATUS_BADGE_COLORS[evaluations[row.index].status]"
              >
                {{ STATUS_LABELS[evaluations[row.index].status] }}
              </VBadge>
              <VBtn
                v-if="row.fixedSource || row.noMatch"
                circle
                color="primary"
                title="Clear selection, use the automatic match"
                @click="emit('clear-selection', { index: row.index })"
              >
                <VIcon
                  x-small
                  name="reset"
                />
              </VBtn>
            </div>
            <div
              v-if="evaluations[row.index].selectionOutOfScope"
              class="subtle margin-xsmall-top"
            >
              Your selection isn't in this project; set aside while only
              this project's Sources are matched.
            </div>
          </td>

          <td class="source-cell">
            <template v-if="evaluations[row.index].source">
              <a
                :href="sourceUrl(evaluations[row.index].source.id)"
                target="_blank"
                v-html="evaluations[row.index].source.object_label"
              />
              <div class="horizontal-left-content gap-small margin-xsmall-top">
                <VBadge
                  v-if="evaluations[row.index].source.in_project === false"
                  class="line-nowrap"
                  color="purple"
                >
                  Not in project
                </VBadge>
                <CheckChips
                  v-if="selectedEvaluation(row)"
                  :evaluation="selectedEvaluation(row)"
                />
              </div>
            </template>
          </td>

          <td>
            <VBtn
              v-if="row.candidates.length"
              color="primary"
              medium
              @click="toggleExpanded(row.index)"
            >
              {{ passingCount(row) }} of {{ row.candidates.length }}
              {{ pluralize(passingCount(row), 'passes', 'pass') }}
              {{ expanded.has(row.index) ? '▴' : '▾' }}
            </VBtn>
          </td>

          <td class="refine-cell">
            <Autocomplete
              v-if="!row.isEmpty"
              url="/sources/autocomplete"
              param="term"
              label="label"
              min="2"
              clear-after
              placeholder="Search for a Source..."
              @get-item="(item) => emit('select-source', { index: row.index, item })"
            />
          </td>

          <td>{{ exportedSourceIds[row.index] }}</td>
        </tr>

        <tr
          v-if="expanded.has(row.index)"
          class="candidates-row"
        >
          <td />
          <td colspan="6">
            <CandidateList
              :row="row"
              :evaluation="evaluations[row.index]"
              :exported-source-id="exportedSourceIds[row.index]"
              @select-candidate="emit('select-candidate', $event)"
              @select-none="emit('select-none', $event)"
            />
          </td>
        </tr>
      </template>
    </tbody>
  </table>
</template>

<script setup>
import { ref } from 'vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import { pluralize } from '@/helpers/strings.js'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'
import CandidateList from './CandidateList.vue'
import CheckChips from './CheckChips.vue'
import { inputSummary, parsedSummary } from '../utils/summaries.js'
import {
  ROW_FILTER,
  ROW_FILTER_LABELS,
  STATUS_BADGE_COLORS,
  STATUS_LABELS
} from '../constants.js'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  },

  // row index => evaluateRow() result, for every row
  evaluations: {
    type: Object,
    required: true
  },

  // row index => the id the row exports (matched or selected), else null
  exportedSourceIds: {
    type: Array,
    required: true
  },

  // { status:, source:, sourceId: } copyable columns, one line per row
  columnTexts: {
    type: Object,
    required: true
  },

  filter: {
    type: String,
    default: ROW_FILTER.ALL
  }
})

const emit = defineEmits([
  'select-candidate',
  'select-source',
  'select-none',
  'clear-selection',
  'update:filter'
])

const expanded = ref(new Set())

function toggleExpanded(index) {
  const next = new Set(expanded.value)
  if (next.has(index)) {
    next.delete(index)
  } else {
    next.add(index)
  }
  expanded.value = next
}

function passingCount(row) {
  return props.evaluations[row.index].evaluations.filter((e) => e.passes)
    .length
}

// The evaluation of the shown Source, when it is one of the candidates.
function selectedEvaluation(row) {
  const evaluation = props.evaluations[row.index]
  const i = row.candidates.findIndex(
    (c) => c.source.id === evaluation.source?.id
  )
  return i < 0 ? null : evaluation.evaluations[i]
}

function expandAll() {
  expanded.value = new Set(
    props.rows.filter((row) => row.candidates.length).map((row) => row.index)
  )
}

function sourceUrl(id) {
  return `/sources/${id}`
}
</script>

<style scoped>
thead th {
  position: sticky;
  top: 0;
  z-index: 1;
}

.input-cell {
  max-width: 360px;
}

.source-cell {
  max-width: 420px;
}

.refine-cell {
  min-width: 220px;
}

/* .table-striped sets a background on every td, so status tints must target
   td, with !important to beat its nth-of-type specificity. */
.row-unmatched td {
  background-color: var(--badge-red-bg) !important;
}

.row-ambiguous td {
  background-color: var(--badge-yellow-bg) !important;
}

.row-empty td {
  opacity: 0.5;
}
</style>
