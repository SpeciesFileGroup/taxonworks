<template>
  <table class="full_width">
    <thead>
      <tr>
        <th class="w-2">
          <div class="horizontal-left-content middle gap-small">
            <input
              type="checkbox"
              :checked="allSelected"
              title="Select all"
              @change="$emit('toggle-all', $event.target.checked)"
            />
            <ButtonUnify
              :ids="selectedIds"
              :model="OTU"
            />
          </div>
        </th>
        <th>OTU name</th>
        <th>Match</th>
        <th>
          <div class="horizontal-left-content middle gap-small">
            <span>Predicted match</span>
            <VBtn
              color="primary"
              title="Clear every selected prediction"
              @click="$emit('clear-predictions')"
            >
              Clear
            </VBtn>
          </div>
        </th>
        <th class="w-2" />
        <th>Refine</th>
        <th class="w-3">
          <div class="horizontal-left-content middle gap-small">
            <span>Set</span>
            <select
              class="normal-input"
              :value="visibility"
              title="Which rows to show"
              @change="$emit('update:visibility', $event.target.value)"
            >
              <option :value="VISIBILITY.All">All</option>
              <option :value="VISIBILITY.Set">Set</option>
              <option :value="VISIBILITY.Unset">Unset</option>
            </select>
          </div>
        </th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="row in rows"
        :key="row.otuId"
        :class="{
          'row-no-match': !row.candidates.length,
          'row-set': row.set
        }"
      >
        <td>
          <input
            type="checkbox"
            :checked="row.selected"
            @change="update(row, 'selected', $event.target.checked)"
          />
        </td>

        <td>
          <a
            :href="`${RouteNames.BrowseOtu}?otu_id=${row.otuId}`"
            target="_blank"
            v-text="row.otuName"
          />
        </td>

        <td>
          <input
            type="text"
            class="normal-input full_width"
            :value="row.matchString"
            @change="$emit('update-match-string', row, $event.target.value)"
          />
        </td>

        <td :class="{ 'cell-ambiguous': row.ambiguous }">
          <span
            v-if="!row.candidates.length"
            class="subtle"
          >
            No match
          </span>
          <label
            v-for="candidate in row.candidates"
            :key="candidate.id"
            class="horizontal-left-content middle gap-small"
          >
            <input
              type="radio"
              :name="`candidate-${row.otuId}`"
              :checked="row.taxonNameId === candidate.id"
              @change="update(row, 'taxonNameId', candidate.id)"
            />
            <a
              :href="`${RouteNames.BrowseNomenclature}?taxon_name_id=${candidate.id}`"
              target="_blank"
              v-html="candidate.cached_html"
            />
            <span
              v-if="candidate.cached_author_year"
              class="subtle"
              v-text="candidate.cached_author_year"
            />
          </label>
        </td>

        <td>
          <VBtn
            circle
            color="primary"
            title="Search the OTU name in Refine"
            @click="prefillRefine(row)"
          >
            <VIcon
              x-small
              name="zoomIn"
            />
          </VBtn>
        </td>

        <td>
          <AutoselectField
            :ref="(el) => setRefineRef(row.otuId, el)"
            url="/taxon_names/autoselect"
            param="taxon_name_id"
            :id="`refine-${row.otuId}`"
            :new-record-component="TaxonNameNewModal"
            placeholder="Refine..."
            @select="(item) => $emit('refine', row, item)"
          />
        </td>

        <td>
          <div class="horizontal-left-content middle gap-small">
            <VBtn
              v-if="!row.set"
              color="create"
              medium
              :disabled="!row.taxonNameId"
              title="Set this taxon name on the OTU"
              @click="$emit('set', row)"
            >
              Set
            </VBtn>
            <span
              v-else
              class="subtle"
            >
              Set
            </span>
            <span
              v-if="row.error"
              class="feedback feedback-danger"
              v-text="row.error"
            />
          </div>
        </td>
      </tr>
    </tbody>
  </table>
</template>

<script setup>
import { computed, ref } from 'vue'
import { VISIBILITY } from '../constants'
import { OTU } from '@/constants'
import { RouteNames } from '@/routes/routes'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import ButtonUnify from '@/components/ui/Button/ButtonUnify.vue'
import TaxonNameNewModal from '@/components/ui/AutoselectField/TaxonNameNewModal.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  },

  visibility: {
    type: String,
    required: true
  }
})

const emit = defineEmits([
  'clear-predictions',
  'refine',
  'set',
  'toggle-all',
  'update-match-string',
  'update-row',
  'update:visibility'
])

const allSelected = computed(
  () => props.rows.length > 0 && props.rows.every((r) => r.selected)
)

const selectedIds = computed(() =>
  props.rows.filter((r) => r.selected).map((r) => r.otuId)
)

// AutoselectField instances, keyed by OTU id, so a row's search can be driven from its button.
const refineRefs = ref({})

function setRefineRef(otuId, el) {
  if (el) {
    refineRefs.value[otuId] = el
  } else {
    delete refineRefs.value[otuId]
  }
}

// Hand the OTU's own name to Refine and start the search there, caret at the end so the
// curator can trim the string immediately. The OTU name is used rather than the (possibly
// stripped) match string — that search has already been run and produced the predictions.
function prefillRefine(row) {
  refineRefs.value[row.otuId]?.prefill(row.otuName)
}

function update(row, field, value) {
  emit('update-row', row, field, value)
}
</script>

<style scoped>
/* Ambiguous: candidates resolve to genuinely different valid taxa. A caution, not an error. */
.cell-ambiguous {
  background-color: var(--feedback-warning-bg-color);
}

/* No candidates is de-emphasis, not danger — red is reserved for destructive actions. */
.row-no-match td {
  background-color: var(--feedback-secondary-bg-color);
}

.row-set td {
  opacity: 0.6;
}
</style>
