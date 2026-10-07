<template>
  <table class="table-striped full_width result-table">
    <thead>
      <tr>
        <th>#</th>
        <th>Row</th>
        <th>
          <div class="horizontal-left-content middle gap-small">
            <span>Status</span>
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
          Source
        </th>
        <th>Candidates</th>
        <th
          data-help="Search for and select a Source, overriding the automatic match."
        >
          Refine
        </th>
        <th>Source id</th>
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
              <div
                class="subtle"
                title="How the row was read"
              >
                {{ parsedSummary(row.parsed) }}
              </div>
            </template>
          </td>

          <td>
            <VBadge :color="STATUS_BADGE_COLORS[evaluations[row.index].status]">
              {{ STATUS_LABELS[evaluations[row.index].status] }}
            </VBadge>
          </td>

          <td class="source-cell">
            <template v-if="evaluations[row.index].source">
              <div class="horizontal-left-content gap-small">
                <a
                  :href="browseSourceUrl(evaluations[row.index].source.id)"
                  target="_blank"
                  v-html="evaluations[row.index].source.object_label"
                />
                <VBtn
                  v-if="row.fixedSource"
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
              {{ passingCount(row) }} / {{ row.candidates.length }}
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

          <td>{{ evaluations[row.index].source?.id }}</td>
        </tr>

        <tr
          v-if="expanded.has(row.index)"
          class="candidates-row"
        >
          <td />
          <td colspan="6">
            <div
              v-for="(candidate, i) in row.candidates"
              :key="candidate.source.id"
              :class="[
                'candidate',
                { 'candidate-failing': !evaluations[row.index].evaluations[i].passes }
              ]"
            >
              <input
                type="radio"
                :name="`candidate-${row.index}`"
                :checked="evaluations[row.index].source?.id === candidate.source.id"
                @change="emit('select-candidate', { index: row.index, candidate })"
              />
              <a
                :href="browseSourceUrl(candidate.source.id)"
                target="_blank"
                v-html="candidate.source.object_label"
              />
              <div class="candidate-checks">
                <VBadge
                  v-if="!candidate.in_project"
                  class="line-nowrap"
                  color="purple"
                >
                  Not in project
                </VBadge>
                <CheckChips :evaluation="evaluations[row.index].evaluations[i]" />
              </div>
            </div>
          </td>
        </tr>
      </template>
    </tbody>
  </table>
</template>

<script setup>
import { ref } from 'vue'
import { SOURCE } from '@/constants'
import { makeBrowseUrl } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import VBadge from '@/components/ui/VBadge/VBadge.vue'
import Autocomplete from '@/components/ui/Autocomplete.vue'
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

  filter: {
    type: String,
    default: ROW_FILTER.ALL
  }
})

const emit = defineEmits([
  'select-candidate',
  'select-source',
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

function browseSourceUrl(id) {
  return makeBrowseUrl({ id, type: SOURCE })
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

.subtle {
  color: var(--text-muted-color);
  font-size: 0.85em;
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

.candidate {
  display: grid;
  grid-template-columns: auto minmax(0, 1fr) 320px;
  align-items: center;
  gap: 8px;
  padding: 2px 0;
}

.candidate-checks {
  display: flex;
  align-items: center;
  gap: 4px;
}

.candidate-failing,
.candidate-failing a {
  color: var(--text-muted-color);
}
</style>
