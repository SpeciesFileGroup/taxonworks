<template>
  <VSpinner
    v-if="loading"
    full-screen
  />

  <h1>Table annotator</h1>

  <NavBar navbar-class="panel content table-annotator-navbar">
    <div class="flex-separate middle">
      <div>
        <span
          v-if="objectType"
          class="small_type"
        >
          <strong>{{ typeLabel(objectType) }}</strong>
          — {{ objects.length }} row{{ objects.length === 1 ? '' : 's' }} loaded
        </span>
      </div>
      <div class="d-flex middle gap-small">
        <VBtn
          v-if="objectType && filterUrl"
          color="primary"
          :href="filterHref"
          :title="isIdsOnlyQuery
            ? 'Opens the filter task with no facets set'
            : 'Reopens the filter task with the same query'"
          target="_blank"
          rel="noopener"
        >
          Open {{ typeLabel(objectType) }} filter
        </VBtn>
        <VBtn
          v-if="objectType"
          color="primary"
          @click="reset"
        >
          Load a different set
        </VBtn>
      </div>
    </div>
  </NavBar>

  <!-- Hub-entry form: no query param present -->
  <template v-if="!objectType && !loading">
    <BlockLayout
      expand
      class="margin-medium-bottom"
    >
      <template #header>
        <h3>Choose objects to annotate</h3>
      </template>

      <template #body>
        <div class="field label-above">
          <label for="type_picker">Object type</label>
          <select
            id="type_picker"
            v-model="pickedType"
          >
            <option
              value=""
              disabled
            >
              Select a type…
            </option>
            <option
              v-for="opt in TYPE_OPTIONS"
              :key="opt.value"
              :value="opt.value"
            >
              {{ opt.label }}
            </option>
          </select>
        </div>

        <template v-if="pickedType">
          <div class="field label-above margin-medium-top">
            <label>Load from filter</label>
            <div class="d-flex middle gap-small">
              <VBtn
                color="primary"
                :href="pickedFilterUrl"
                target="_blank"
                rel="noopener"
                :disabled="!pickedFilterUrl"
              >
                Open {{ typeLabel(pickedType) }} filter task
              </VBtn>
              <span class="small_type">
                Use the linker in the filter task to send results here.
              </span>
            </div>
          </div>

          <div class="field label-above margin-medium-top">
            <label>Paste IDs (comma or whitespace separated)</label>
            <textarea
              v-model="pastedIds"
              rows="3"
              class="full_width"
              placeholder="e.g. 12, 34, 56"
            />
            <div class="margin-small-top">
              <VBtn
                color="create"
                :disabled="!parsedPastedIds.length"
                @click="loadFromPastedIds"
              >
                Load {{ parsedPastedIds.length || '' }} {{ typeLabel(pickedType) }}
              </VBtn>
            </div>
          </div>
        </template>
      </template>
    </BlockLayout>
  </template>

  <!-- Grid: query param present, rows loaded -->
  <template v-else-if="objectType && !loading">
    <BlockLayout
      expand
      class="margin-medium-bottom"
    >
      <template #header>
        <h3>Annotations</h3>
      </template>

      <template #body>
        <div
          v-if="objects.length === 0"
          class="feedback feedback-info padding-small text-center"
        >
          No rows loaded.
        </div>

        <div
          v-else
          class="annotator-grid"
          role="table"
          aria-label="Table annotator grid"
          :style="{ gridTemplateColumns }"
        >
          <div
            class="annotator-grid-row annotator-grid-header"
            role="row"
          >
            <div role="columnheader">Object</div>
            <div
              v-for="col in columns"
              :key="col.cvtId"
              role="columnheader"
              class="annotator-grid-col"
            >
              <div class="d-flex flex-col gap-small">
                <div class="d-flex middle gap-small">
                  <span
                    class="col-name"
                    :title="col.cvtName"
                    v-html="col.cvtName"
                  />
                  <span
                    class="col-usage small_type"
                    :title="`Applied to ${col.usageCount} of ${objects.length} loaded rows`"
                  >{{ col.usageCount }}/{{ objects.length }}</span>
                  <span
                    class="button button-circle btn-undo button-default"
                    title="Remove column from view (does not delete data)"
                    @click="removeColumn(col.cvtId)"
                  />
                </div>
                <div class="d-flex middle gap-small">
                  <input
                    v-if="col.type === 'keyword'"
                    type="checkbox"
                    v-model="bulkColumnValues[col.cvtId]"
                    title="Apply to all rows"
                  />
                  <input
                    v-else
                    type="text"
                    class="cell-input"
                    v-model="bulkColumnValues[col.cvtId]"
                    placeholder="Apply to all"
                  />
                  <VBtn
                    v-if="hasBulkValue(col)"
                    color="primary"
                    small
                    @click="applyBulkColumn(col)"
                  >
                    Apply
                  </VBtn>
                </div>
              </div>
            </div>
            <div
              role="columnheader"
              class="annotator-grid-addcol"
            >
              <div
                v-if="showAddColumn"
                class="d-flex flex-col gap-small add-column-picker"
              >
                <Autocomplete
                  class="add-column-autocomplete"
                  url="/controlled_vocabulary_terms/autocomplete"
                  :add-params="{ type: ['Keyword', 'Predicate'] }"
                  placeholder="Search vocabulary"
                  param="term"
                  min="1"
                  clear-after
                  label="label_html"
                  @get-item="pickColumnCvt"
                />
                <div
                  v-if="newColumnCvt"
                  class="small_type"
                >
                  Selected:
                  <span v-html="newColumnCvt.label_html || newColumnCvt.label" />
                </div>
                <div class="d-flex middle gap-small">
                  <VBtn
                    color="primary"
                    small
                    :disabled="!newColumnCvt"
                    @click="addColumn"
                  >
                    Add
                  </VBtn>
                  <VBtn
                    color="primary"
                    small
                    @click="cancelAddColumn"
                  >
                    Cancel
                  </VBtn>
                  <a
                    href="/tasks/controlled_vocabularies/manage"
                    target="_blank"
                    rel="noopener"
                    class="small_type margin-small-left"
                  >
                    New term
                  </a>
                </div>
              </div>
              <VBtn
                v-else
                color="primary"
                circle
                small
                title="Add a controlled vocabulary column"
                @click="openAddColumn"
              >
                +
              </VBtn>
            </div>
            <div
              role="columnheader"
              aria-hidden="true"
              class="annotator-grid-spacer"
            />
          </div>

          <div
            v-for="obj in objects"
            :key="obj.id"
            class="annotator-grid-row"
            role="row"
          >
            <div role="cell">
              <div class="d-flex middle gap-small">
                <span
                  class="button button-circle btn-undo button-default"
                  title="Remove from view (does not delete the object)"
                  @click="removeObject(obj.id)"
                />
                <span
                  class="ellipsis"
                  v-html="objectLabel(obj)"
                />
              </div>
            </div>
            <div
              v-for="col in columns"
              :key="col.cvtId"
              role="cell"
              class="annotator-grid-col"
            >
              <input
                v-if="col.type === 'keyword'"
                type="checkbox"
                :data-cell="`cv:${col.cvtId}:${obj.id}`"
                :checked="!!cellData[col.cvtId]?.[obj.id]?.value"
                @change="toggleKeywordCell(col.cvtId, obj.id, $event.target.checked)"
                @keydown.enter.prevent="focusNextRowSameColumn(`cv:${col.cvtId}`, obj.id)"
              />
              <input
                v-else
                type="text"
                class="cell-input"
                :data-cell="`cv:${col.cvtId}:${obj.id}`"
                :value="cellData[col.cvtId]?.[obj.id]?.value ?? ''"
                @input="setPredicateCell(col.cvtId, obj.id, $event.target.value)"
                @blur="commitPredicateCell(col.cvtId, obj.id)"
                @keydown.enter.prevent="commitPredicateCell(col.cvtId, obj.id); focusNextRowSameColumn(`cv:${col.cvtId}`, obj.id)"
              />
            </div>
            <div
              role="cell"
              class="annotator-grid-addcol"
            />
            <div
              role="cell"
              aria-hidden="true"
              class="annotator-grid-spacer"
            />
          </div>
        </div>
      </template>
    </BlockLayout>
  </template>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete.vue'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import NavBar from '@/components/layout/NavBar.vue'
import VBtn from '@/components/ui/VBtn/index.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import { ControlledVocabularyTerm, DataAttribute, Tag } from '@/routes/endpoints'
import { QUERY_PARAMETER } from '@/tasks/data_attributes/field_synchronize/constants'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'
import { ID_PARAM_FOR } from '@/components/radials/filter/constants/idParams'
import { useQueryParam } from '@/tasks/data_attributes/field_synchronize/composables/useQueryParam'
import qs from 'qs'
import { computed, onBeforeMount, reactive, ref } from 'vue'

const TYPE_LABELS = {
  AssertedDistribution: 'Asserted distributions',
  BiologicalAssociation: 'Biological associations',
  CollectingEvent: 'Collecting events',
  CollectionObject: 'Collection objects',
  Content: 'Contents',
  Descriptor: 'Descriptors',
  Extract: 'Extracts',
  FieldOccurrence: 'Field occurrences',
  Image: 'Images',
  Loan: 'Loans',
  Observation: 'Observations',
  Otu: 'OTUs',
  Person: 'People',
  Sound: 'Sounds',
  Source: 'Sources',
  TaxonName: 'Taxon names'
}

const TYPE_OPTIONS = Object.entries(TYPE_LABELS)
  .map(([value, label]) => ({ value, label }))
  .sort((a, b) => a.label.localeCompare(b.label))

const loading = ref(false)
const objectType = ref(null)
const service = ref(null)
const filterUrl = ref(null)
const activeQueryParam = ref(null)
const activeQueryValue = ref(null)
const objects = ref([])
const columns = ref([])
const cellData = reactive({})
const originalCellData = reactive({})
const bulkColumnValues = reactive({})
const showAddColumn = ref(false)
const newColumnCvt = ref(null)
const pickedType = ref('')
const pastedIds = ref('')

const gridTemplateColumns = computed(() => {
  const cvCount = columns.value.length
  return ['max-content',
    ...Array(cvCount).fill('max-content'),
    'max-content',
    '1fr'
  ].join(' ')
})

const pickedFilterUrl = computed(() =>
  pickedType.value ? QUERY_PARAMETER[QUERY_PARAM[pickedType.value]]?.filterUrl : null
)

const isIdsOnlyQuery = computed(() => {
  if (!activeQueryValue.value || !objectType.value) return false
  const idParam = ID_PARAM_FOR[objectType.value]
  const keys = Object.keys(activeQueryValue.value)
  return keys.length === 1 && keys[0] === idParam
})

const filterHref = computed(() => {
  if (!filterUrl.value) return null
  if (isIdsOnlyQuery.value || !activeQueryParam.value) return filterUrl.value
  const search = qs.stringify({ [activeQueryParam.value]: activeQueryValue.value })
  return `${filterUrl.value}?${search}`
})

const parsedPastedIds = computed(() => {
  return (pastedIds.value.match(/\d+/g) || []).map(Number)
})

function typeLabel(t) {
  return TYPE_LABELS[t] ?? t
}

function objectLabel(obj) {
  return obj.object_tag || obj.label_html || obj.name || `#${obj.id}`
}

function hasBulkValue(col) {
  const v = bulkColumnValues[col.cvtId]
  if (col.type === 'keyword') return !!v
  return (v ?? '') !== ''
}

function reset() {
  window.location.href = window.location.pathname
}

function loadFromPastedIds() {
  if (!pickedType.value || !parsedPastedIds.value.length) return
  const idParam = ID_PARAM_FOR[pickedType.value]
  const queryParam = QUERY_PARAM[pickedType.value]
  const search = qs.stringify({
    [queryParam]: { [idParam]: parsedPastedIds.value }
  })
  window.location.href = `${window.location.pathname}?${search}`
}

function pickColumnCvt(item) {
  ControlledVocabularyTerm.find(item.id)
    .then(({ body }) => {
      if (body.type !== 'Keyword' && body.type !== 'Predicate') {
        TW.workbench.alert.create(
          `Only Keyword and Predicate vocabulary terms can be used as columns (this is a ${body.type || 'unknown type'}).`,
          'error'
        )
        newColumnCvt.value = null
        return
      }
      newColumnCvt.value = {
        id: body.id,
        type: body.type,
        name: body.name,
        label: item.label,
        label_html: item.label_html
      }
    })
    .catch(() => {
      newColumnCvt.value = null
    })
}

function openAddColumn() {
  showAddColumn.value = true
  newColumnCvt.value = null
}

function cancelAddColumn() {
  showAddColumn.value = false
  newColumnCvt.value = null
}

function addColumn() {
  if (!newColumnCvt.value) return
  if (columns.value.some((c) => c.cvtId === newColumnCvt.value.id)) {
    cancelAddColumn()
    return
  }
  columns.value.push({
    type: newColumnCvt.value.type === 'Keyword' ? 'keyword' : 'predicate',
    cvtId: newColumnCvt.value.id,
    cvtName: newColumnCvt.value.label || newColumnCvt.value.name,
    usageCount: 0
  })
  cancelAddColumn()
}

function removeColumn(cvtId) {
  columns.value = columns.value.filter((c) => c.cvtId !== cvtId)
}

function removeObject(objectId) {
  objects.value = objects.value.filter((o) => o.id !== objectId)
  recountColumnUsage()
}

function recountColumnUsage() {
  const objectIds = new Set(objects.value.map((o) => o.id))
  columns.value = columns.value.map((col) => {
    const rowsWithValue = Object.entries(cellData[col.cvtId] ?? {})
      .filter(([objId, cell]) => objectIds.has(Number(objId)) && cellHasValue(col, cell))
      .length
    return { ...col, usageCount: rowsWithValue }
  })
}

function cellHasValue(col, cell) {
  if (!cell) return false
  if (col.type === 'keyword') return !!cell.value
  return (cell.value ?? '').toString().length > 0
}

function focusNextRowSameColumn(colKey, currentObjectId) {
  const idx = objects.value.findIndex((o) => o.id === currentObjectId)
  if (idx < 0 || idx >= objects.value.length - 1) return
  const nextId = objects.value[idx + 1].id
  const next = document.querySelector(`[data-cell="${colKey}:${nextId}"]`)
  if (next) {
    next.focus()
    if (typeof next.select === 'function') next.select()
  }
}

function setPredicateCell(cvtId, objectId, value) {
  if (!cellData[cvtId]) cellData[cvtId] = {}
  const cur = cellData[cvtId][objectId] ?? { id: null, value: '' }
  cellData[cvtId] = {
    ...cellData[cvtId],
    [objectId]: { ...cur, value }
  }
}

function commitPredicateCell(cvtId, objectId) {
  autoSaveCell(cvtId, objectId)
}

function toggleKeywordCell(cvtId, objectId, checked) {
  if (!cellData[cvtId]) cellData[cvtId] = {}
  const cur = cellData[cvtId][objectId] ?? { id: null, value: false }
  cellData[cvtId] = {
    ...cellData[cvtId],
    [objectId]: { ...cur, value: !!checked }
  }
  autoSaveCell(cvtId, objectId)
}

function applyBulkColumn(col) {
  const target = bulkColumnValues[col.cvtId]
  if (!hasBulkValue(col)) return

  objects.value.forEach((obj) => {
    if (col.type === 'keyword') {
      toggleKeywordCell(col.cvtId, obj.id, true)
    } else {
      setPredicateCell(col.cvtId, obj.id, target)
      autoSaveCell(col.cvtId, obj.id)
    }
  })

  bulkColumnValues[col.cvtId] = col.type === 'keyword' ? false : ''
}

const savingCells = new Map()

function autoSaveCell(cvtId, objectId) {
  const cellKey = `${cvtId}:${objectId}`
  if (savingCells.get(cellKey)) return

  const col = columns.value.find((c) => c.cvtId === cvtId)
  if (!col) return

  const cur = cellData[cvtId]?.[objectId]
  const orig = originalCellData[cvtId]?.[objectId]
  const curVal = cur?.value ?? null
  const origVal = orig?.value ?? null
  if (curVal === origVal) return

  savingCells.set(cellKey, true)

  const releaseAndRecheck = () => {
    savingCells.delete(cellKey)
    const newCur = cellData[cvtId]?.[objectId]
    const newOrig = originalCellData[cvtId]?.[objectId]
    if ((newCur?.value ?? null) !== (newOrig?.value ?? null)) {
      autoSaveCell(cvtId, objectId)
    }
  }

  const rebaseline = (updated) => {
    if (!originalCellData[cvtId]) originalCellData[cvtId] = {}
    const map = { ...originalCellData[cvtId] }
    if (updated === null) {
      delete map[objectId]
    } else {
      map[objectId] = updated
    }
    originalCellData[cvtId] = map
    if (updated) {
      cellData[cvtId] = {
        ...cellData[cvtId],
        [objectId]: updated
      }
    } else if (cellData[cvtId]) {
      const cd = { ...cellData[cvtId] }
      delete cd[objectId]
      cellData[cvtId] = cd
    }
    recountColumnUsage()
    releaseAndRecheck()
  }

  const revert = () => {
    if (orig) {
      cellData[cvtId] = {
        ...cellData[cvtId],
        [objectId]: { ...orig }
      }
    } else if (cellData[cvtId]) {
      const cd = { ...cellData[cvtId] }
      delete cd[objectId]
      cellData[cvtId] = cd
    }
    savingCells.delete(cellKey)
  }

  if (col.type === 'predicate') {
    const value = (cur?.value ?? '').toString()
    if (cur?.id) {
      if (value === '') {
        DataAttribute.destroy(cur.id)
          .then(() => rebaseline(null))
          .catch(revert)
      } else {
        DataAttribute.update(cur.id, { data_attribute: { value } })
          .then(({ body }) => rebaseline({ id: body.id ?? cur.id, value }))
          .catch(revert)
      }
    } else if (value !== '') {
      DataAttribute.create({
        data_attribute: {
          attribute_subject_type: objectType.value,
          attribute_subject_id: objectId,
          controlled_vocabulary_term_id: cvtId,
          type: 'InternalAttribute',
          value
        }
      })
        .then(({ body }) => rebaseline({ id: body.id, value }))
        .catch(revert)
    } else {
      rebaseline(null)
    }
    return
  }

  // Keyword
  const wantTag = !!cur?.value
  if (wantTag && !orig?.id) {
    Tag.create({
      tag: {
        keyword_id: cvtId,
        tag_object_type: objectType.value,
        tag_object_id: objectId
      }
    })
      .then(({ body }) => rebaseline({ id: body.id, value: true }))
      .catch(revert)
  } else if (!wantTag && orig?.id) {
    Tag.destroy(orig.id)
      .then(() => rebaseline(null))
      .catch(revert)
  }
}

function autoPopulateColumns() {
  return ControlledVocabularyTerm.forObjectType(objectType.value)
    .then(({ body: cvts }) => {
      const objectIds = new Set(objects.value.map((o) => o.id))
      const existing = new Set(columns.value.map((c) => c.cvtId))
      const additions = []

      cvts.forEach((cvt) => {
        if (existing.has(cvt.id)) return
        const usageCount = countLoadedRowsWithValue(cvt.id, cvt.type, objectIds)
        additions.push({
          cvtId: cvt.id,
          cvtName: cvt.name,
          type: cvt.type === 'Keyword' ? 'keyword' : 'predicate',
          usageCount
        })
      })

      columns.value = [...columns.value, ...additions]
        .sort((a, b) => b.usageCount - a.usageCount || a.cvtName.localeCompare(b.cvtName))
    })
    .catch(() => {})
}

function countLoadedRowsWithValue(cvtId, cvtType, objectIds) {
  const cells = cellData[cvtId]
  if (!cells) return 0
  let n = 0
  Object.entries(cells).forEach(([objId, cell]) => {
    if (!objectIds.has(Number(objId))) return
    if (cvtType === 'Keyword') {
      if (cell?.value) n++
    } else if ((cell?.value ?? '').toString().length > 0) {
      n++
    }
  })
  return n
}

function loadCellData() {
  const objectIds = objects.value.map((o) => o.id)
  if (!objectIds.length) return Promise.resolve()

  const daPromise = DataAttribute.filter({
    attribute_subject_type: [objectType.value],
    attribute_subject_id: objectIds,
    per: 5000
  })

  const tagPromise = Tag.filter({
    tag_object_type: [objectType.value],
    tag_object_id: objectIds,
    per: 5000
  })

  return Promise.all([daPromise, tagPromise]).then(
    ([{ body: das }, { body: tags }]) => {
      Object.keys(cellData).forEach((k) => delete cellData[k])
      Object.keys(originalCellData).forEach((k) => delete originalCellData[k])

      das.forEach((da) => {
        const cvtId = da.controlled_vocabulary_term_id
        const cvtName = da.controlled_vocabulary_term?.name ??
                        da.predicate_name ??
                        `#${cvtId}`
        if (!cellData[cvtId]) cellData[cvtId] = {}
        if (!originalCellData[cvtId]) originalCellData[cvtId] = {}
        const cell = {
          id: da.id,
          value: da.value ?? '',
          cvtName,
          columnType: 'predicate'
        }
        cellData[cvtId][da.attribute_subject_id] = cell
        originalCellData[cvtId][da.attribute_subject_id] = { id: cell.id, value: cell.value }
      })

      tags.forEach((tag) => {
        const cvtId = tag.keyword_id
        const cvtName = tag.keyword?.name ?? `#${cvtId}`
        if (!cellData[cvtId]) cellData[cvtId] = {}
        if (!originalCellData[cvtId]) originalCellData[cvtId] = {}
        const cell = {
          id: tag.id,
          value: true,
          cvtName,
          columnType: 'keyword'
        }
        cellData[cvtId][tag.tag_object_id] = cell
        originalCellData[cvtId][tag.tag_object_id] = { id: cell.id, value: true }
      })
    }
  ).catch(() => {})
}

function loadRows({ queryParam, queryValue }) {
  const entry = QUERY_PARAMETER[queryParam]
  if (!entry) {
    TW.workbench.alert.create(
      `Unknown object type for query param "${queryParam}".`,
      'error'
    )
    return Promise.resolve()
  }

  objectType.value = entry.model
  service.value = entry.service
  filterUrl.value = entry.filterUrl
  activeQueryParam.value = queryParam
  activeQueryValue.value = queryValue
  loading.value = true

  return entry.service
    .filter({ ...queryValue, per: 5000 })
    .then(({ body }) => {
      objects.value = body
    })
    .then(() => loadCellData())
    .then(() => autoPopulateColumns())
    .catch(() => {
      TW.workbench.alert.create('Failed to load rows.', 'error')
    })
    .finally(() => {
      loading.value = false
    })
}

onBeforeMount(() => {
  const { queryParam, queryValue } = useQueryParam()
  if (queryParam.value && queryValue.value) {
    loadRows({ queryParam: queryParam.value, queryValue: queryValue.value })
  }
})
</script>

<style scoped>
.table-annotator-navbar {
  margin-bottom: 1rem;
}

.annotator-grid {
  display: grid;
  width: 100%;
  max-height: 70vh;
  overflow: auto;
}

.annotator-grid-row {
  display: grid;
  grid-template-columns: subgrid;
  grid-column: 1 / -1;
}

.annotator-grid-row > * {
  padding: 0.35rem 0.75rem;
  display: flex;
  align-items: center;
  min-width: 0;
  white-space: nowrap;
}

.annotator-grid > .annotator-grid-row:not(.annotator-grid-header):nth-child(even) {
  background: var(--table-row-bg-odd);
}

.annotator-grid-header {
  position: sticky;
  top: 0;
  z-index: 1;
  background: var(--bg-action);
}

.annotator-grid-header > * {
  align-items: flex-start;
  padding-top: 0.5rem;
  padding-bottom: 0.5rem;
  font-weight: bold;
}

.cell-input {
  width: 14rem;
}

.col-name {
  max-width: 12rem;
  overflow: hidden;
  text-overflow: ellipsis;
}

.col-usage {
  color: var(--text-muted-color);
  font-weight: normal;
}

.add-column-picker {
  min-width: 16rem;
}

.add-column-picker .add-column-autocomplete {
  width: 100%;
}
</style>
