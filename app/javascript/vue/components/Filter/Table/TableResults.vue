<template>
  <div
    id="horizontally-scrollable"
    class="overflow-x-auto"
  >
    <table
      class="table-striped table-cell-border table-header-border full_width"
      v-resize-column
      ref="element"
    >
      <thead ref="theadRef">
        <tr v-if="headerGroups.length || layout?.properties">
          <td
            v-if="headerEmptyColspan"
            class="header-empty-td"
            :colspan="headerEmptyColspan"
          />
          <template
            v-for="header in headerGroups"
            :key="header"
          >
            <component
              v-if="!hideUnfrozen"
              :is="header.title ? 'th' : 'td'"
              :colspan="header.colspan"
              :scope="header.scope"
            >
              {{ header.title }}
            </component>
          </template>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <th
              v-if="getVisiblePropertiesCount(key, getColumns(key, properties))"
              :colspan="
                getVisiblePropertiesCount(key, getColumns(key, properties))
              "
              scope="colgroup"
              class="cell-left-border"
            >
              {{ humanize(key) }}
            </th>
          </template>

          <td
            v-if="!headerGroups.length && !isLayoutConfig"
            :colspan="Object.keys(attributes).length"
          />
        </tr>

        <tr>
          <th
            v-show="isColumnVisible(FIXED_COLUMNS.Checkbox)"
            v-bind="freezeBindings(FIXED_COLUMNS.Checkbox)"
          >
            <VLock
              :value="FIXED_COLUMNS.Checkbox"
              v-model="freezeColumn"
            />
          </th>
          <th
            v-if="radialObject || radialAnnotator || radialNavigator"
            v-show="isColumnVisible(FIXED_COLUMNS.Radial)"
            v-bind="freezeBindings(FIXED_COLUMNS.Radial)"
          >
            <VLock
              :value="FIXED_COLUMNS.Radial"
              v-model="freezeColumn"
            />
          </th>
          <th
            v-for="attr in orderedAttributeKeys"
            :key="attr"
            v-show="isColumnVisible(attr)"
            v-bind="freezeBindings(attr)"
          >
            <ColumnHeaderActions
              :column-key="attr"
              :filtered="!!filterValues[attr]"
              v-model:freeze="freezeColumn"
              :sort-index="sortIndexFor(attr)"
              :sort-dir="sortDirFor(attr)"
              :show-sort-index="sortKeys.length > 1"
              :sortable="isSortable(attr)"
              @copy="
                () =>
                  copyColumnToClipboard(
                    sanitizeHtml(
                      list
                        .filter(rowHasCurrentValues)
                        .map((item) => item[attr])
                        .join('\n')
                    )
                  )
              "
              @sort="(opts) => sortTable(attr, opts)"
              @clear="() => delete filterValues[attr]"
            />
          </th>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <th
              v-for="(property, pIndex) in orderedLayoutColumns(key, properties)"
              :key="property"
              v-show="isColumnVisible(`${key}.${property}`)"
              :class="{ 'cell-left-border': pIndex === 0 }"
              v-bind="freezeBindings(`${key}.${property}`)"
            >
              <ColumnHeaderActions
                :column-key="`${key}.${property}`"
                :filtered="!!filterValues[`${key}.${property}`]"
                v-model:freeze="freezeColumn"
                :sort-index="sortIndexFor(`${key}.${property}`)"
                :sort-dir="sortDirFor(`${key}.${property}`)"
                :show-sort-index="sortKeys.length > 1"
                :sortable="isSortable(`${key}.${property}`)"
                @copy="
                  () =>
                    copyColumnToClipboard(
                      props.list
                        .filter(rowHasCurrentValues)
                        .map((item) => renderItem(item, key, property))
                        .join('\n')
                    )
                "
                @sort="(opts) => sortTable(`${key}.${property}`, opts)"
                @clear="() => delete filterValues[`${key}.${property}`]"
              />
            </th>
          </template>
        </tr>

        <tr class="header-row-attributes">
          <th
            v-show="isColumnVisible(FIXED_COLUMNS.Checkbox)"
            class="w-2"
            :data-th-column="FIXED_COLUMNS.Checkbox"
            v-bind="freezeBindings(FIXED_COLUMNS.Checkbox)"
          >
            <input
              v-model="selectIds"
              :disabled="!list.length"
              type="checkbox"
            />
          </th>
          <th
            v-if="radialObject || radialAnnotator || radialNavigator"
            v-show="isColumnVisible(FIXED_COLUMNS.Radial)"
            class="w-2"
            :data-th-column="FIXED_COLUMNS.Radial"
            v-bind="freezeBindings(FIXED_COLUMNS.Radial)"
          />
          <th
            v-for="attr in orderedAttributeKeys"
            :key="attr"
            v-show="isColumnVisible(attr)"
            :data-th-column="attr"
            :class="[
              'draggable-column-header',
              { 'draggable-column-header-dragging': draggedColumnKey === attr }
            ]"
            v-bind="freezeBindings(attr)"
            draggable="true"
            @mousedown.capture="armColumnDrag"
            @dragstart="(e) => onColumnDragStart(e, attr)"
            @dragover="(e) => onColumnDragOver(e, attr)"
            @drop="(e) => onColumnDrop(e, attr)"
            @dragend="onColumnDragEnd"
          >
            <div class="horizontal-left-content gap-small">
              <span>{{ attributes[attr] }}</span>
            </div>
          </th>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <th
              v-for="(property, pIndex) in orderedLayoutColumns(key, properties)"
              :key="property"
              v-show="isColumnVisible(`${key}.${property}`)"
              :class="[
                'draggable-column-header',
                { 'cell-left-border': pIndex === 0 },
                { 'draggable-column-header-dragging': draggedColumnKey === `${key}.${property}` }
              ]"
              :data-th-column="`${key}.${property}`"
              v-bind="freezeBindings(`${key}.${property}`)"
              :draggable="Array.isArray(properties)"
              @mousedown.capture="armColumnDrag"
              @dragstart="(e) => onColumnDragStart(e, `${key}.${property}`)"
              @dragover="(e) => onColumnDragOver(e, `${key}.${property}`)"
              @drop="(e) => onColumnDrop(e, `${key}.${property}`)"
              @dragend="onColumnDragEnd"
            >
              <div class="horizontal-left-content gap-small">
                <span>{{ property }}</span>
              </div>
            </th>
          </template>
        </tr>
      </thead>
      <tbody @mouseout="($event) => emit('mouseout:body', $event)">
        <tr
          v-for="(item, index) in list"
          :key="item.id"
          :class="{
            'cell-selected-border': item.id === lastRadialOpenedRow
          }"
          v-bind="item._bind"
          v-show="rowHasCurrentValues(item)"
          @mouseover="() => emit('mouseover:row', { index, item })"
        >
          <td
            v-show="isColumnVisible(FIXED_COLUMNS.Checkbox)"
            v-bind="freezeBindings(FIXED_COLUMNS.Checkbox)"
          >
            <input
              v-model="ids"
              :value="item.id"
              type="checkbox"
            />
          </td>
          <td
            v-if="radialObject || radialAnnotator || radialNavigator"
            v-show="isColumnVisible(FIXED_COLUMNS.Radial)"
            v-bind="freezeBindings(FIXED_COLUMNS.Radial)"
          >
            <div class="horizontal-right-content gap-small">
              <slot
                name="buttons-left"
                :item="item"
              />
              <RadialAnnotator
                v-if="radialAnnotator"
                :global-id="item.global_id"
                reload
                teleport
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialObject
                v-if="radialObject"
                :global-id="item.global_id"
                teleport
                @click="() => (lastRadialOpenedRow = item.id)"
              />
              <RadialNavigation
                v-if="radialNavigator"
                :global-id="item.global_id"
                :redirect="false"
                teleport
                @delete="emit('remove', { item, index })"
                @click="() => (lastRadialOpenedRow = item.id)"
              />
            </div>
          </td>
          <template v-if="attributes">
            <td
              v-for="attr in orderedAttributeKeys"
              :key="attr"
              v-show="isColumnVisible(attr)"
              :name="attr"
              :value="item[attr]"
              v-bind="freezeBindings(attr)"
              @dblclick="
                () => {
                  filterValues[attr] = item[attr]
                  scrollToTop()
                  updateSelectedIdsByFilter()
                }
              "
            >
              <slot
                :name="attr"
                :value="item[attr]"
                :set-highlight="() => (lastRadialOpenedRow = item.id)"
              >
                <div v-html="item[attr]" />
              </slot>
            </td>
          </template>

          <template
            v-for="(properties, key) in layout?.properties"
            :key="key"
          >
            <td
              v-for="(property, pIndex) in orderedLayoutColumns(key, properties)"
              :key="property"
              v-show="isColumnVisible(`${key}.${property}`)"
              v-html="renderItem(item, key, property)"
              :class="{ 'cell-left-border': pIndex === 0 }"
              v-bind="freezeBindings(`${key}.${property}`)"
              @dblclick="() => setColumnFilter(item, key, property)"
            />
          </template>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script setup>
import {
  computed,
  nextTick,
  onBeforeUnmount,
  onMounted,
  ref,
  useTemplateRef,
  watch
} from 'vue'
import { vResizeColumn } from '@/directives/resizeColumn.js'
import { humanize } from '@/helpers/strings'
import { sanitizeHtml } from '@/helpers'
import { useUserPreference, useUserPreferences } from '@/composables'
import ColumnHeaderActions from './ColumnHeaderActions.vue'
import VLock from '@/components/ui/VLock/index.vue'
import RadialNavigation from '@/components/radials/navigation/radial.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import RadialObject from '@/components/radials/object/radial.vue'
import 'handy-scroll'

const props = defineProps({
  list: {
    type: Array,
    default: () => []
  },

  modelValue: {
    type: Array,
    default: () => []
  },

  attributes: {
    type: Object,
    default: () => {}
  },

  headerGroups: {
    type: Array,
    default: () => []
  },

  layout: {
    type: Object,
    default: () => {}
  },

  radialObject: {
    type: Boolean,
    default: false
  },

  radialAnnotator: {
    type: Boolean,
    default: true
  },

  radialNavigator: {
    type: Boolean,
    default: true
  },

  preferenceKey: {
    type: String,
    default: null
  },

  // When non-null, only columns whose key appears in this array show a
  // sort button. Frontend gating that mirrors the backend whitelist.
  // Null means "gating disabled" -- all sort buttons show (legacy behavior).
  sortableKeys: {
    type: Array,
    default: null
  },

  // The most sort keys the backend applies; null when not known.
  maxSortKeys: {
    type: Number,
    default: null
  }
})

const emit = defineEmits([
  'remove',
  'reorder:layout',
  'update:modelValue',
  'update:sortKeys',
  'mouseover:row',
  'mouseout:body'
])

const FIXED_COLUMNS = {
  Checkbox: 'FixedCheckboxesColumn',
  Radial: 'FixedRadialColumn'
}

const hideUnfrozen = defineModel('hideUnfrozen', {
  type: Boolean,
  default: false
})

// Session state for freeze / hide. Distinct from pref-backed refs below --
// URL fragment + user changes flow into these without touching the user's
// saved default. `saveViewAsDefault()` copies the current session state to
// the pref refs, which persists to the server.
const freezeColumn = ref([])
const freezeColumnPref = props.preferenceKey
  ? useUserPreference(`${props.preferenceKey}::freezeColumn`, [])
  : ref([])
const hideUnfrozenPref = props.preferenceKey
  ? useUserPreference(`${props.preferenceKey}::hideUnfrozen`, false)
  : ref(false)
const freezeColumnLeftPosition = ref({})

// Column order of an attributes table (attribute keys, e.g. 'name'), empty
// for their natural order. A layout's column order is the layout's own: a
// drag there emits `reorder:layout` for the layout to apply and save, so
// the layout selector shows it and its Reset clears it. Reordering across
// layout sections is not supported -- see drag handlers.
const columnOrder = ref([])
const columnOrderPref = props.preferenceKey
  ? useUserPreference(`${props.preferenceKey}::columnOrder`, [])
  : ref([])
const draggedColumnKey = ref(null)
let draggedColumnSection = null
// Whether the current mousedown can start a column drag: not when it's on a
// column's resize bar (which stops the event before it reaches the th).
let columnDragArmed = false

const { loaded: preferencesLoaded } = useUserPreferences()

// URL fragment sync for view state: `#freeze=key1,key2&hide=true&order=...`.
// Fragment stays out of the query string so it doesn't hit the server or
// consume the (already tight) GET budget. The fragment holds only what
// differs from the user's saved default (pref), including "off" values
// (`freeze=`, `hide=false`, `order=`), so a reload or shared link shows the
// same view. On mount, the fragment overrides the pref.
const VIEW_STATE_PARAMS = ['freeze', 'hide', 'order']

// @return [Object] the fragment's view state params, and its other parts
//   (e.g. an anchor, `#top`) as written
function splitFragment() {
  const parts = window.location.hash.slice(1).split('&').filter(Boolean)
  const isViewState = (part) => VIEW_STATE_PARAMS.includes(part.split('=')[0])
  return {
    params: new URLSearchParams(parts.filter(isViewState).join('&')),
    other: parts.filter((part) => !isViewState(part))
  }
}

function setFragment(params, other) {
  const next = [...other, params.toString()].filter(Boolean).join('&')
  const nextHash = next ? `#${next}` : ''
  if (window.location.hash === nextHash) return
  history.replaceState(
    null,
    '',
    `${window.location.pathname}${window.location.search}${nextHash}`
  )
}

function readViewStateFromFragment() {
  const { params } = splitFragment()
  const rawFreeze = params.get('freeze')
  const rawHide = params.get('hide')
  const rawOrder = params.get('order')
  return {
    freeze:
      rawFreeze == null
        ? null
        : rawFreeze.split(',').map((s) => s.trim()).filter(Boolean),
    hide: rawHide == null ? null : rawHide === 'true',
    order:
      rawOrder == null
        ? null
        : rawOrder.split(',').map((s) => s.trim()).filter(Boolean)
  }
}

function writeViewStateToFragment({ freeze, hide, order }) {
  // The fragment holds differences from the saved default: until that's
  // loaded, there's nothing to compare against (an "off" value would look
  // like the default and be dropped).
  if (props.preferenceKey && !preferencesLoaded.value) return
  const { params, other } = splitFragment()
  if (freeze !== undefined) {
    if (arraysEqual(freeze ?? [], freezeColumnPref.value ?? [])) params.delete('freeze')
    else params.set('freeze', (freeze ?? []).join(','))
  }
  if (hide !== undefined) {
    if (!!hide === !!hideUnfrozenPref.value) params.delete('hide')
    else params.set('hide', hide ? 'true' : 'false')
  }
  if (order !== undefined) {
    if (arraysEqual(order ?? [], columnOrderPref.value ?? [])) params.delete('order')
    else params.set('order', (order ?? []).join(','))
  }
  setFragment(params, other)
}

function clearViewStateFragment() {
  setFragment(new URLSearchParams(), splitFragment().other)
}

const orderedAttributeKeys = computed(() => {
  const known = Object.keys(props.attributes || {})
  if (!columnOrder.value.length) return known
  const inOrder = columnOrder.value.filter((k) => known.includes(k))
  const missing = known.filter((k) => !inOrder.includes(k))
  return [...inOrder, ...missing]
})

// Computed once per change, not per row: the body template calls
// orderedLayoutColumns for every row.
const orderedLayoutColumnsBySection = computed(() =>
  Object.fromEntries(
    Object.entries(props.layout?.properties || {}).map(([k, ps]) => [
      k,
      getColumns(k, ps)
    ])
  )
)

function orderedLayoutColumns(sectionKey, properties) {
  return (
    orderedLayoutColumnsBySection.value[sectionKey] ??
    getColumns(sectionKey, properties)
  )
}

// In layout mode keys are '<section>.<column>' and reordering stays within a
// section. Attribute keys can contain dots too (e.g. 'keyword.object_tag'),
// but attribute tables have no sections.
function columnSection(key) {
  return props.layout?.properties ? key.split('.')[0] : null
}

function armColumnDrag(e) {
  columnDragArmed = !e.target.closest('.vue-column-resize-bar')
}

function onColumnDragStart(e, key) {
  if (!columnDragArmed) {
    e.preventDefault()
    return
  }
  columnDragArmed = false
  draggedColumnKey.value = key
  draggedColumnSection = columnSection(key)
  e.dataTransfer.effectAllowed = 'move'
  // Firefox requires data to be set to initiate a drag.
  try { e.dataTransfer.setData('text/plain', key) } catch (_) {}
}

function onColumnDragOver(e, key) {
  if (!draggedColumnKey.value) return
  const targetSection = columnSection(key)
  if (targetSection !== draggedColumnSection) return
  e.preventDefault()
  e.dataTransfer.dropEffect = 'move'
}

function onColumnDrop(e, key) {
  const dragged = draggedColumnKey.value
  draggedColumnKey.value = null
  if (!dragged || dragged === key) return
  const targetSection = columnSection(key)
  if (targetSection !== draggedColumnSection) return
  e.preventDefault()

  if (targetSection) {
    const section = targetSection
    const prefix = `${section}.`
    const columns = moveItem(
      orderedLayoutColumns(section, props.layout.properties[section]),
      dragged.slice(prefix.length),
      key.slice(prefix.length)
    )
    if (columns) emit('reorder:layout', { section, columns })
    return
  }

  const next = moveItem(orderedAttributeKeys.value, dragged, key)
  if (!next) return
  // Back in the natural order is no order.
  columnOrder.value = arraysEqual(next, Object.keys(props.attributes || {}))
    ? []
    : next
}

// @return [Array|null] list with item moved to where target is
function moveItem(list, item, target) {
  const next = [...list]
  const fromIdx = next.indexOf(item)
  const toIdx = next.indexOf(target)
  if (fromIdx === -1 || toIdx === -1) return null
  next.splice(fromIdx, 1)
  next.splice(toIdx, 0, item)
  return next
}

function onColumnDragEnd() {
  columnDragArmed = false
  draggedColumnKey.value = null
  draggedColumnSection = null
}

function isColumnVisible(key) {
  return !hideUnfrozen.value || freezeColumn.value.includes(key)
}

function getVisiblePropertiesCount(key, properties) {
  return properties.filter((p) => isColumnVisible(`${key}.${p}`)).length
}

function freezeBindings(key) {
  const isFrozen = freezeColumn.value.includes(key)

  return {
    class: { freeze: isFrozen },
    style: isFrozen ? { left: freezeColumnLeftPosition.value[key] } : undefined
  }
}

function generateFreezeColumnLeftPosition() {
  const obj = {}
  const sizes = {}
  const columns = [...document.querySelectorAll(`[data-th-column]`)]
    .map((el) => el.getAttribute('data-th-column'))
    .filter((attr) => freezeColumn.value.includes(attr))

  columns.forEach((attr, index) => {
    const el = document.querySelector(`[data-th-column="${attr}"]`)
    const rect = el.getBoundingClientRect()
    const sizeValues = Object.values(obj)
    const size =
      index === 0
        ? 0
        : sizeValues.slice(0, index).reduce((acc, curr) => acc + curr, 0)

    obj[attr] = rect.width
    sizes[attr] = size + 'px'
  })

  freezeColumnLeftPosition.value = sizes
}

const headerEmptyColspan = computed(() => {
  const hasRadial =
    props.radialObject || props.radialAnnotator || props.radialNavigator
  let n = 0
  if (isColumnVisible(FIXED_COLUMNS.Checkbox)) n++
  if (hasRadial && isColumnVisible(FIXED_COLUMNS.Radial)) n++
  return n
})

const sortKeys = defineModel('sortKeys', {
  type: Array,
  default: () => []
})
const lastRadialOpenedRow = ref(null)
const handyScrollRef = useTemplateRef('handyScrollRef')
const theadRef = useTemplateRef('theadRef')
const tableRef = useTemplateRef('element')
let tableResizeObserver = null
const isLayoutConfig = computed(() => !!Object.keys(props.layout || {}).length)

const filterValues = ref({})

function getValue(item, property) {
  const properties = property.split('.')

  return properties.reduce((acc, curr) => {
    return Array.isArray(acc) ? acc.map((item) => item?.[curr]) : acc?.[curr]
  }, item)
}

function rowHasCurrentValues(item) {
  return Object.entries(filterValues.value).every(([properties, value]) => {
    const itemValue = getValue(item, properties)

    return Array.isArray(itemValue)
      ? itemValue.some((i) => value.includes(i))
      : itemValue === value
  })
}

const filteredIds = computed(() =>
  props.list.filter(rowHasCurrentValues).map((item) => item.id)
)

function clearFilterValues() {
  filterValues.value = {}
}

const selectIds = computed({
  get: () =>
    filteredIds.value.length === props.modelValue.length &&
    filteredIds.value.length > 0,
  set: (value) => emit('update:modelValue', value ? [...filteredIds.value] : [])
})

const ids = computed({
  get: () => props.modelValue,
  set: (value) => emit('update:modelValue', value)
})

function updateSelectedIdsByFilter() {
  ids.value = ids.value.filter((id) => filteredIds.value.includes(id))
}

function computeHeaderRowTops() {
  if (!theadRef.value) return

  let cumulative = 0
  ;[...theadRef.value.querySelectorAll('tr')].forEach((row, index) => {
    theadRef.value.style.setProperty(
      `--row-${index + 1}-top`,
      `${cumulative}px`
    )
    cumulative += row.getBoundingClientRect().height
  })
}

function copyColumnToClipboard(text) {
  navigator.clipboard
    .writeText(text)
    .then(() => {
      TW.workbench.alert.create('Copied to clipboard', 'notice')
    })
    .catch(() => {})
}

function renderItem(item, listType, property) {
  const value = item[listType]

  return Array.isArray(value)
    ? value.map((obj) => obj[property]).join('; ')
    : value && value[property]
}

function getDynamicColumns(type) {
  const [item] = props.list

  return props.layout.properties[type].show && item
    ? Object.keys(item[type])
    : []
}

function getColumns(key, properties) {
  return Array.isArray(properties) ? properties : getDynamicColumns(key)
}

function setColumnFilter(item, key, property) {
  scrollToTop()
  filterValues.value[`${key}.${property}`] = Array.isArray(item[key])
    ? item[key].map((obj) => obj[property])
    : item[key][property]
  updateSelectedIdsByFilter()
}

function sortIndexFor(key) {
  const i = sortKeys.value.findIndex((s) => s.key === key)
  return i === -1 ? null : i
}

function sortDirFor(key) {
  return sortKeys.value.find((s) => s.key === key)?.dir ?? null
}

// null = gating disabled, everything sortable. Otherwise, only keys in the
// list are sortable (matches the backend's sortable_columns whitelist).
function isSortable(key) {
  if (props.sortableKeys == null) return true
  return props.sortableKeys.includes(key)
}

// Cycle: empty -> asc -> desc -> removed.
// Shift-click appends to the current sort list and cycles within it, up to
// the backend's limit.
// Plain click replaces the list with the clicked column.
function sortTable(sortProperty, { shiftKey } = {}) {
  let next
  if (shiftKey) {
    next = [...sortKeys.value]
    const idx = next.findIndex((s) => s.key === sortProperty)
    if (idx === -1) {
      if (props.maxSortKeys != null && next.length >= props.maxSortKeys) {
        TW.workbench.alert.create(
          `At most ${props.maxSortKeys} columns can be sorted at once.`,
          'notice'
        )
        return
      }
      next.push({ key: sortProperty, dir: 'asc' })
    } else if (next[idx].dir === 'asc') {
      next[idx] = { key: sortProperty, dir: 'desc' }
    } else {
      next.splice(idx, 1)
    }
  } else {
    const current = sortKeys.value
    if (current.length === 1 && current[0].key === sortProperty) {
      if (current[0].dir === 'asc') {
        next = [{ key: sortProperty, dir: 'desc' }]
      } else {
        next = []
      }
    } else {
      next = [{ key: sortProperty, dir: 'asc' }]
    }
  }

  // Parent watches sortKeys (v-model) and re-fetches.
  sortKeys.value = next
}

function scrollToTop() {
  document.getElementById('horizontally-scrollable')?.scrollTo(0, 0)
}

onMounted(() => {
  nextTick(computeHeaderRowTops)

  if (tableRef.value && typeof ResizeObserver !== 'undefined') {
    tableResizeObserver = new ResizeObserver(() => {
      requestAnimationFrame(generateFreezeColumnLeftPosition)
    })
    tableResizeObserver.observe(tableRef.value)
  }

  // Initial view state: URL fragment > user pref > default.
  const fromFragment = readViewStateFromFragment()
  freezeColumn.value =
    fromFragment.freeze ?? freezeColumnPref.value ?? []
  hideUnfrozen.value =
    fromFragment.hide ?? hideUnfrozenPref.value ?? false
  columnOrder.value = isLayoutConfig.value
    ? []
    : (fromFragment.order ?? columnOrderPref.value ?? [])
})

// Cold start (no sessionStorage cache): preferences arrive after mount.
// Apply them once, when they finish loading -- not on later changes, e.g. a
// preference saved in another tab -- and only where the fragment and the
// user haven't already set the state. Then bring the fragment up to date,
// as its writes waited for the preferences.
watch(preferencesLoaded, (loaded) => {
  if (!loaded || !props.preferenceKey) return
  const fromFragment = readViewStateFromFragment()
  if (fromFragment.freeze == null && !freezeColumn.value.length) {
    freezeColumn.value = [...(freezeColumnPref.value ?? [])]
  }
  if (fromFragment.hide == null && !hideUnfrozen.value) {
    hideUnfrozen.value = !!hideUnfrozenPref.value
  }
  if (
    !isLayoutConfig.value &&
    fromFragment.order == null &&
    !columnOrder.value.length
  ) {
    columnOrder.value = [...(columnOrderPref.value ?? [])]
  }
  writeViewStateToFragment({
    freeze: freezeColumn.value,
    hide: hideUnfrozen.value,
    order: isLayoutConfig.value ? undefined : columnOrder.value
  })
})

watch(
  freezeColumn,
  (next) => writeViewStateToFragment({ freeze: next }),
  { deep: true }
)

watch(hideUnfrozen, (next) =>
  writeViewStateToFragment({ hide: next })
)

watch(
  columnOrder,
  (next) => {
    if (!isLayoutConfig.value) writeViewStateToFragment({ order: next })
  },
  { deep: true }
)

onBeforeUnmount(() => {
  tableResizeObserver?.disconnect()
})

watch(
  () => props.list,
  (newVal, oldVal) => {
    nextTick(() => {
      handyScrollRef.value?.update()
    })

    if (oldVal && oldVal?.length === newVal?.length) {
      const ids = oldVal.map((item) => item.id)
      const hasSameIds = newVal.every((item) => ids.includes(item.id))

      if (!hasSameIds) {
        clearFilterValues()
        scrollToTop()
      }
    } else {
      clearFilterValues()
    }
  },
  { immediate: true }
)

watch(
  [() => props.layout, () => props.attributes, freezeColumn, hideUnfrozen, columnOrder],
  () =>
    nextTick(() => {
      generateFreezeColumnLeftPosition()
      computeHeaderRowTops()
    }),
  {
    deep: true
  }
)

watch(
  () => props.layout,
  () => {
    nextTick(() => {
      handyScrollRef.value?.update()
    })
  },
  { deep: true }
)

// Copies current session view state (freeze + hide + order) into the user's
// saved preferences. Called by the SaveViewButton at the filter task level,
// which also saves sort separately since that state lives in the parent.
function saveViewAsDefault() {
  // Deep-clone to strip Vue reactive proxies before persisting.
  freezeColumnPref.value = JSON.parse(JSON.stringify(freezeColumn.value))
  hideUnfrozenPref.value = hideUnfrozen.value
  // A layout's column order is saved with the layout.
  if (!isLayoutConfig.value) {
    columnOrderPref.value = JSON.parse(JSON.stringify(columnOrder.value))
  }
  // The view is now the default, so the fragment has nothing to override.
  // Cleared directly: the prefs set above are saved asynchronously, so
  // comparing against them here would still see the old values.
  clearViewStateFragment()
}

// Compare current freeze/hide session state against pref; drives the
// "unsaved changes" model that the parent uses to show/hide the Save button.
const unsavedViewChanges = defineModel('unsavedViewChanges', {
  type: Boolean,
  default: false
})

function arraysEqual(a, b) {
  if (a === b) return true
  if (!Array.isArray(a) || !Array.isArray(b)) return false
  if (a.length !== b.length) return false
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return false
  return true
}

watch(
  [freezeColumn, hideUnfrozen, columnOrder, freezeColumnPref, hideUnfrozenPref, columnOrderPref],
  ([fz, hd, ord, fzPref, hdPref, ordPref]) => {
    if (!props.preferenceKey) {
      unsavedViewChanges.value = false
      return
    }
    const freezeDirty = !arraysEqual(fz, fzPref ?? [])
    const hideDirty = hd !== (hdPref ?? false)
    const orderDirty =
      !isLayoutConfig.value && !arraysEqual(ord, ordPref ?? [])
    unsavedViewChanges.value = freezeDirty || hideDirty || orderDirty
  },
  { deep: true, immediate: true }
)

defineExpose({
  clearFilterValues,
  saveViewAsDefault
})
</script>

<style scoped>
table {
  border-collapse: separate;
}
.cell-left-border {
  border-left: 3px var(--border-color) solid;
}

.row-dwc-reindex-pending,
.cell-selected-border {
  outline-offset: -2px;

  .freeze::before {
    content: '';
    position: absolute;
    left: 0;
    top: 0;
    width: 100%;
    height: 2px;
  }

  .freeze::after {
    content: '';
    position: absolute;
    left: 0;
    bottom: 0;
    width: 100%;
    height: 1.5px;
  }
}

.row-dwc-reindex-pending {
  outline: 2px solid var(--color-attention);

  .freeze {
    border-bottom: 1px solid var(--color-attention);
  }

  .freeze::before,
  .freeze::after {
    background-color: var(--color-attention);
  }
}

.cell-selected-border {
  outline: 2px solid var(--color-primary) !important;

  .freeze {
    border-bottom: 1px solid var(--color-primary) !important;
  }

  .freeze::before,
  .freeze::after {
    background-color: var(--color-primary);
  }
}

#horizontally-scrollable {
  height: 100%;
}

thead th,
thead td {
  position: sticky;
  background-color: var(--panel-bg-color, #fff);
  z-index: 12;
}

thead tr:nth-child(1) th,
thead tr:nth-child(1) td {
  top: var(--row-1-top, 0px);
}

thead tr:nth-child(2) th,
thead tr:nth-child(2) td {
  top: var(--row-2-top, 0px);
}

thead tr:nth-child(3) th,
thead tr:nth-child(3) td {
  top: var(--row-3-top, 0px);
}

.freeze {
  left: 0;
  position: sticky;
  z-index: 10;
}

thead .freeze {
  z-index: 15;
}

.header-empty-td {
  border-bottom: 2px solid var(--border-color);
}

.header-row-attributes {
  th {
    font-weight: 700;
  }
}

.draggable-column-header {
  cursor: grab;
}

.draggable-column-header:active {
  cursor: grabbing;
}

.draggable-column-header-dragging {
  opacity: 0.4;
}

:deep(.handy-scroll) {
  z-index: 11;
}
</style>
