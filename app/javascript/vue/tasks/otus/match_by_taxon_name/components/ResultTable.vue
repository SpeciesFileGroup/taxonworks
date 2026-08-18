<template>
  <table class="table-striped full_width">
    <thead>
      <tr>
        <th data-help="Check rows to restrict option changes and regex application to only those rows. When none are checked, all rows currently visible (per the TaxonName/OTU filters) are affected.">
          <input
            type="checkbox"
            :checked="allSelected"
            @change="toggleSelectAll($event.target.checked)"
          />
        </th>
        <th />
        <th class="line-nowrap">scientificName <ButtonClipboard :text="columnClipboardText('scientificName')" title="Copy scientificName column" /></th>
        <th class="line-nowrap" data-help="Override the string used for matching. Leave blank to match using the scientificName value as-is. A manually-entered value shows a small dot. Regex modifiers (left panel) write to this field automatically.">Match <ButtonClipboard :text="columnClipboardText('match')" title="Copy match column" /></th>
        <th class="line-nowrap" data-help="A yellow cell indicates that there was more than one matching Taxon Name to choose from, so you may want to confirm the name selected - if the wrong name was selected you can select the correct one in the Refine column.">
          <div class="horizontal-left-content middle gap-small">
            <span>TaxonName</span>
            <select
              class="normal-input"
              :value="taxonNameFilter"
              title="Which rows to show"
              @change="emit('update:taxonNameFilter', $event.target.value)"
            >
              <option
                v-for="[label, value] in Object.entries(TAXON_NAME_FILTER)"
                :key="value"
                :value="value"
              >
                {{ label }}
              </option>
            </select>
            <ButtonClipboard :text="columnClipboardText('taxonName')" title="Copy TaxonName column" />
          </div>
        </th>
        <th />
        <th class="w-2" />
        <th data-help="Manually search for and select a TaxonName, overriding the automatic match result. Use this to fix incorrect or ambiguous matches.">Refine</th>
        <th
          class="line-nowrap"
          data-help="'User selected' means the OTU was fixed by the user (radio click or Create OTU) rather than merely auto-picked, so it survives re-matches."
        >
          <div class="horizontal-left-content middle gap-small">
            <span>OTU</span>
            <select
              class="normal-input"
              :value="otuFilter"
              title="Which rows to show"
              @change="emit('update:otuFilter', $event.target.value)"
            >
              <option
                v-for="[label, value] in Object.entries(OTU_FILTER)"
                :key="value"
                :value="value"
              >
                {{ label }}
              </option>
            </select>
            <ButtonClipboard :text="columnClipboardText('otuLabel')" title="Copy OTU column" />
          </div>
        </th>
        <th class="line-nowrap">OTU id <ButtonClipboard :text="columnClipboardText('otuId')" title="Copy OTU id column" /></th>
        <th />
        <th>Set</th>
      </tr>
    </thead>
    <tbody>
      <tr
        v-for="row in rows"
        :key="row.index"
        :data-row-index="row.index"
        :class="{
          'row-disabled': isDuplicate(row),
          'row-no-match': !row.matched && !row.isEmpty,
          'row-empty': row.isEmpty
        }"
      >
        <!-- select -->
        <td>
          <input
            type="checkbox"
            :checked="row.selected"
            :disabled="isDuplicate(row) || row.isEmpty"
            @change="
              (e) => {
                emit('update-row', {
                  index: row.index,
                  field: 'selected',
                  value: e.target.checked
                })
              }
            "
          />
        </td>

        <!-- context -->
        <td>
          <button
            v-if="csvData"
            class="circle-button"
            :disabled="!row.csvRow"
            @click="openContext(row)"
          >
            <span>i</span>
          </button>
        </td>

        <!-- scientificName -->
        <td>
          <span
            v-if="row.isEmpty"
            class="empty-label"
            >EMPTY</span
          >
          <span v-else>{{ row.scientificName }}</span>
        </td>

        <!-- match -->
        <td class="cell-interactive">
          <div class="horizontal-left-content gap-xsmall">
            <span class="match-icon-slot">
              <span
                v-if="row.userMatchString"
                class="user-match-dot"
                title="Manually entered — overrides the automatic scientificName-based match."
              />
            </span>
            <input
              v-if="!row.isEmpty"
              type="text"
              class="normal-input match-input"
              :value="row.userMatchString || row.regexMatchString"
              placeholder="(uses scientificName)"
              @change="
                (e) => {
                  emit('update-row', { index: row.index, field: 'userMatchString', value: e.target.value })
                  emit('match-row', { index: row.index })
                }
              "
            />
            <span v-else>{{ row.userMatchString || row.regexMatchString }}</span>
          </div>
        </td>

        <!-- TaxonName -->
        <td :class="{ 'cell-ambiguous': row.ambiguous }">
          <a
            v-if="row.taxonName"
            :href="browseTaxonNameUrl(row.taxonNameId)"
            target="_blank"
            v-html="row.taxonName.cached_html"
          />
        </td>

        <!-- radials -->
        <td>
          <div
            v-if="row.taxonName?.global_id"
            class="horizontal-left-content gap-xsmall"
          >
            <RadialAnnotator :global-id="row.taxonName.global_id" />
            <RadialNavigator :global-id="row.taxonName.global_id" />
          </div>
        </td>

        <!-- search scientificName in Refine -->
        <td>
          <VBtn
            v-if="isActionable(row)"
            circle
            color="primary"
            :disabled="row.fixedOtuId != null"
            title="Search the scientificName in Refine"
            @click="prefillRefine(row)"
          >
            <VIcon
              x-small
              name="zoomIn"
            />
          </VBtn>
        </td>

        <!-- reselect (Refine) -->
        <td>
          <AutoselectField
            v-if="isActionable(row)"
            :ref="(el) => setRefineRef(row.index, el)"
            url="/taxon_names/autoselect"
            param="taxon_name_id"
            :id="`match-taxon-name-refine-${row.index}`"
            :new-record-component="TaxonNameNewModal"
            reset-on-select
            :disabled="row.fixedOtuId != null"
            placeholder="Search taxon name..."
            @select="
              (item) =>
                emit('update-row', {
                  index: row.index,
                  field: 'taxonName',
                  value: item
                })
            "
          />
        </td>

        <!-- OTU -->
        <td>
          <span v-if="row.fixedOtuId != null">{{ row.fixedOtuName }}</span>
          <template v-else-if="row.otus.length">
            <div
              v-for="otu in row.otus"
              :key="otu.id"
              class="horizontal-left-content gap-xsmall"
            >
              <input
                type="radio"
                :name="'otu-select-' + row.index"
                :value="otu.id"
                :checked="row.selectedOtuId === otu.id"
                :disabled="isDuplicate(row)"
                @click="selectOtu(row, otu)"
                @change="selectOtu(row, otu)"
              />
              <span>{{ otu.object_label || otu.name || `OTU ${otu.id}` }}</span>
            </div>
          </template>
        </td>

        <!-- OTU id -->
        <td>
          <a
            v-if="row.selectedOtuId"
            :href="browseOtuUrl(row.selectedOtuId)"
            target="_blank"
          >
            {{ row.selectedOtuId }}
          </a>
        </td>

        <!-- create OTU -->
        <td>
          <div class="horizontal-left-content gap-xsmall">
            <VBtn
              v-if="isActionable(row) && row.taxonNameId && !row.otus.length && row.fixedOtuId == null"
              color="create"
              @click="emit('create-otu', { index: row.index })"
            >
              Create OTU
            </VBtn>
            <VBtn
              v-if="row.fixedOtuId != null"
              circle
              color="primary"
              title="Clear fixed OTU selection"
              @click="
                emit('update-row', {
                  index: row.index,
                  field: 'fixedOtuId',
                  value: null
                })
              "
            >
              <VIcon
                x-small
                name="reset"
              />
            </VBtn>
          </div>
        </td>

        <!-- set (duplicate link) -->
        <td>
          <a
            v-if="isDuplicate(row)"
            href="#"
            @click.prevent="emit('scroll-to-row', activeRowIndex(row))"
          >
            → row {{ activeRowIndex(row) + 1 }}
          </a>
        </td>
      </tr>
    </tbody>
  </table>

  <!-- Context modal -->
  <div
    v-if="contextRow"
    class="modal-mask"
    @click.self="contextRow = null"
  >
    <div class="modal-container">
      <div class="flex-row flex-separate middle margin-medium-bottom">
        <h3>Row context</h3>
        <VBtn
          circle
          color="primary"
          @click="contextRow = null"
        >
          <VIcon
            x-small
            name="close"
          />
        </VBtn>
      </div>
      <table class="table-striped full_width">
        <tbody>
          <tr
            v-for="(value, key) in contextRow.csvRow"
            :key="key"
          >
            <td>
              <strong>{{ key }}</strong>
            </td>
            <td>{{ value }}</td>
          </tr>
        </tbody>
      </table>
    </div>
  </div>
</template>

<script setup>
import { ref, computed } from 'vue'
import { OTU, TAXON_NAME } from '@/constants'
import { makeBrowseUrl } from '@/helpers'
import VBtn from '@/components/ui/VBtn/index.vue'
import VIcon from '@/components/ui/VIcon/index.vue'
import AutoselectField from '@/components/ui/AutoselectField.vue'
import TaxonNameNewModal from '@/components/ui/AutoselectField/TaxonNameNewModal.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialNavigator from '@/components/radials/navigation/radial.vue'
import ButtonClipboard from '@/components/ui/Button/ButtonClipboard.vue'
import effectiveName from '../utils/effectiveName.js'
import { TAXON_NAME_FILTER, OTU_FILTER } from '../constants.js'

const props = defineProps({
  rows: {
    type: Array,
    required: true
  },

  csvData: {
    type: Object,
    default: null
  },

  taxonNameFilter: {
    type: String,
    default: TAXON_NAME_FILTER.All
  },

  otuFilter: {
    type: String,
    default: OTU_FILTER.All
  }
})

const emit = defineEmits([
  'update-row',
  'create-otu',
  'scroll-to-row',
  'match-row',
  'update:taxonNameFilter',
  'update:otuFilter'
])

const contextRow = ref(null)

// AutoselectField instances, keyed by row index, so a row's Refine search can be driven from its
// button.
const refineRefs = ref({})

function setRefineRef(index, el) {
  if (el) {
    refineRefs.value[index] = el
  } else {
    delete refineRefs.value[index]
  }
}

// Hand the row's scientificName to Refine and start the search there, caret at the end so the
// curator can trim the string immediately.
function prefillRefine(row) {
  refineRefs.value[row.index]?.prefill(row.scientificName)
}

const selectableRows = computed(() =>
  props.rows.filter((r) => !r.isEmpty && !isDuplicate(r))
)

const allSelected = computed(
  () =>
    selectableRows.value.length > 0 &&
    selectableRows.value.every((r) => r.selected)
)

function toggleSelectAll(checked) {
  props.rows.forEach((row) => {
    if (!row.isEmpty && !isDuplicate(row)) {
      emit('update-row', {
        index: row.index,
        field: 'selected',
        value: checked
      })
    }
  })
}

function browseTaxonNameUrl(id) {
  return makeBrowseUrl({ id, type: TAXON_NAME })
}

function browseOtuUrl(id) {
  return makeBrowseUrl({ id, type: OTU })
}

// Maps effectiveName -> the index of its first occurrence in props.rows.
const firstIndexByEffectiveName = computed(() => {
  const map = new Map()
  props.rows.forEach((row) => {
    const name = effectiveName(row)
    if (!map.has(name)) {
      map.set(name, row.index)
    }
  })
  return map
})

function firstUniqueIndex(row) {
  return firstIndexByEffectiveName.value.get(effectiveName(row))
}

function isDuplicate(row) {
  if (row.isEmpty) return false
  return firstUniqueIndex(row) !== row.index
}

function isActionable(row) {
  return !isDuplicate(row) && !row.isEmpty
}

function selectOtu(row, otu) {
  emit('update-row', { index: row.index, field: 'selectedOtuId', value: otu })
}

function activeRowIndex(row) {
  return firstUniqueIndex(row)
}

function openContext(row) {
  if (row.csvRow) {
    contextRow.value = row
  }
}

function columnClipboardText(field) {
  const values = props.rows.map((row) => {
    switch (field) {
      case 'scientificName':
        return row.scientificName || ''
      case 'match':
        return effectiveName(row)
      case 'taxonName':
        return row.taxonName?.cached || ''
      case 'otuLabel': {
        if (row.fixedOtuId != null) return row.fixedOtuName || ''
        const otu = row.otus.find((o) => o.id === row.selectedOtuId)
        return otu?.object_label || otu?.name || ''
      }
      case 'otuId':
        return row.selectedOtuId != null ? String(row.selectedOtuId) : ''
      default:
        return ''
    }
  })

  return values.join('\n')
}
</script>

<style scoped>
thead th {
  position: sticky;
  top: 0;
  z-index: 1;
}

.match-input {
  width: 200px;
}

.match-icon-slot {
  display: inline-flex;
  align-items: center;
  flex-shrink: 0;
  width: var(--size-xSmall);
}

.user-match-dot {
  display: inline-block;
  width: var(--size-xxSmall);
  height: var(--size-xxSmall);
  border-radius: 50%;
  background-color: var(--badge-blue-color);
}

/* !important needed: .table-striped's tr:nth-of-type(even/odd) td rule has
   higher specificity than a single class here. */
.cell-ambiguous {
  background-color: var(--badge-yellow-bg) !important;
}

.row-disabled td {
  opacity: 0.6;
}

.row-disabled .cell-interactive {
  opacity: 1;
}

/* .table-striped sets a background directly on every td, and border-collapse
   leaves tr no visible area of its own to paint into — so a tr-level
   background-color (even with !important) is invisible; it must target td. */
.row-no-match td {
  background-color: var(--badge-red-bg) !important;
}

.row-empty td {
  background-color: var(--bg-muted) !important;
}

.row-empty {
  opacity: 0.5;
}

.empty-label {
  color: var(--text-muted-color);
  font-style: italic;
  font-size: 0.85em;
}

.circle-button {
  width: 24px;
  height: 24px;
  border-radius: 50%;
  border: 1px solid var(--border-color);
  background: var(--input-bg-color);
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 12px;
  font-style: italic;
  font-weight: bold;
  color: var(--text-muted-color);
}

.circle-button:disabled {
  opacity: 0.4;
  cursor: default;
}

.modal-mask {
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background-color: var(--modal-mask-bg-color);
  z-index: 9999;
  display: flex;
  align-items: center;
  justify-content: center;
}

.modal-container {
  background: var(--panel-bg-color);
  border-radius: var(--border-radius-xsmall);
  padding: 24px;
  max-width: 600px;
  max-height: 80vh;
  overflow-y: auto;
  width: 90%;
}
</style>
