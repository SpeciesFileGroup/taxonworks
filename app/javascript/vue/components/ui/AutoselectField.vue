<template>
  <div class="autoselect-field">
    <!-- Fuse bar — always visible, segmented, above input -->
    <div class="autoselect-field__fuse-track">
      <div
        v-for="(seg, idx) in fuseSegments"
        :key="seg.key"
        class="autoselect-field__fuse-segment"
        :class="[
          seg.external
            ? 'autoselect-field__fuse-segment--external'
            : 'autoselect-field__fuse-segment--internal',
          {
            'autoselect-field__fuse-segment--ignited': ignitedSegmentIdx === idx
          },
          {
            'autoselect-field__fuse-segment--active':
              fuseSegments[idx]?.key === currentLevel
          }
        ]"
        @click="onFuseSegmentClick(seg, idx)"
        @mouseenter="hoveredSegmentIdx = idx"
        @mouseleave="hoveredSegmentIdx = null"
      >
        <!-- Orange ignition sweep -->
        <div
          v-if="ignitedSegmentIdx === idx"
          class="autoselect-field__fuse-ignition"
          :style="{ transitionDuration: currentFuseMs + 'ms' }"
          :class="{ 'autoselect-field__fuse-ignition--running': fuseRunning }"
        />

        <!-- Hover tooltip -->
        <div
          v-if="hoveredSegmentIdx === idx"
          class="autoselect-field__fuse-tooltip"
        >
          <span class="autoselect-field__fuse-tooltip-trigger"
            >!{{ idx + 1 }}</span
          >
          <span class="autoselect-field__fuse-tooltip-label">{{
            seg.label
          }}</span>
          <span class="autoselect-field__fuse-tooltip-desc">{{
            seg.description
          }}</span>
        </div>
      </div>
    </div>

    <!-- Input with inline spinner -->
    <div class="autoselect-field__input-wrap">
      <input
        ref="inputEl"
        type="text"
        class="autoselect-field__input normal-input"
        :placeholder="placeholder"
        :disabled="disabled || !ready"
        v-model="inputText"
        autocomplete="off"
        @input="onInput"
        @keydown.down.prevent="moveSelection(1)"
        @keydown.up.prevent="moveSelection(-1)"
        @keydown.enter.prevent="confirmHighlighted"
        @keydown.escape="onEscape"
        @focus="onFocus"
        @blur="onBlur"
      />
      <span
        v-if="isSearching"
        class="autoselect-field__input-spinner"
        :title="spinnerTitle"
      >
        <component :is="currentSpinner" />
      </span>
    </div>

    <!-- Dropdown — visible only after a search completes (searchEnd), matching Autocomplete.vue -->
    <teleport to="body">
      <ul
        v-if="showList && searchEnd"
        v-show="showList"
        class="autoselect-field__dropdown"
        ref="dropdownEl"
        :style="dropdownStyle"
        @mousedown="onDropdownMousedown"
      >
        <template v-if="dropdownItems.length">
          <li
            v-for="(item, idx) in dropdownItems"
            :key="item.id ?? 'item-' + idx"
            class="autoselect-field__dropdown-item"
            :class="{
              'autoselect-field__dropdown-item--active': idx === current
            }"
            @mouseover="current = idx"
            @click.prevent="itemClicked(idx)"
          >
            <span v-html="item.label_html || item.label" />
            <span
              v-if="item.info"
              class="autoselect-field__item-info"
              >{{ item.info }}</span
            >
          </li>
        </template>
        <li
          v-else
          class="autoselect-field__dropdown-none"
        >
          --None--
        </li>
      </ul>
    </teleport>

    <!-- Help overlay (shown on !? operator) -->
    <div
      v-if="showHelp"
      class="autoselect-field__help-overlay"
    >
      <h4>Available operators</h4>
      <ul>
        <li
          v-for="op in visibleOperators"
          :key="op.trigger"
        >
          <code>{{ op.trigger }}</code> — {{ op.description }}
        </li>
      </ul>
      <button
        class="btn"
        @click="showHelp = false"
      >
        Close
      </button>
    </div>

    <!-- CoL confirmation modal — teleported to body so it renders above all stacking contexts -->
    <Teleport to="body">
      <ColConfirmModal
        v-if="pendingExtensionItem?.extension?.col_key"
        :item="pendingExtensionItem"
        @confirm="onColConfirm"
        @cancel="cancelExtension"
      />
    </Teleport>

    <!-- OTU new-record modal — opened by the !n operator -->
    <Teleport to="body">
      <OtuNewModal
        v-if="newOtuName !== null"
        :name-prefill="newOtuName"
        @confirm="onOtuCreated"
        @cancel="cancelOtuNew"
      />
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { useAutoselect } from '@/components/ui/AutoselectField/useAutoselect'
import ColConfirmModal from '@/components/ui/AutoselectField/ColConfirmModal.vue'
import OtuNewModal from '@/components/ui/AutoselectField/OtuNewModal.vue'
import CatalogueOfLifeSpinner from '@/components/ui/AutoselectField/CatalogueOfLifeSpinner.vue'
import TaxonWorksSpinner from '@/components/ui/AutoselectField/TaxonWorksSpinner.vue'

const LEVEL_SPINNERS = {
  catalog_of_life: CatalogueOfLifeSpinner
}

// ── Props & emits ──────────────────────────────────────────────────────────────
const props = defineProps({
  url: { type: String, required: true },
  modelValue: { type: Object, default: null },
  param: { type: String, required: true },
  placeholder: { type: String, default: 'Search...' },
  disabled: { type: Boolean, default: false },
  levelDelay: { type: Number, default: 500 } // debounce ms; exposed for playground tuning
})

const emit = defineEmits(['update:modelValue', 'select'])

// ── Composable ─────────────────────────────────────────────────────────────────
const { config, fetchConfig, getFirstLevelKey, isExternalLevel, getOperators } =
  useAutoselect(props.url)

// ── Refs ───────────────────────────────────────────────────────────────────────
const inputEl = ref(null)
const dropdownEl = ref(null)

// search state — mirrors Autocomplete.vue naming closely
const ready = ref(false)
const inputText = ref('')
const currentLevel = ref(null)
const dropdownItems = ref([])
const current = ref(-1) // highlighted index
const isSearching = ref(false)
const searchEnd = ref(false) // true after first search completes (gates dropdown)
const showList = ref(false)
const dropdownStyle = ref({})
const controller = ref(null) // AbortController
let getRequest = 0 // debounce handle (matches Autocomplete.vue name)

// fuse state
const fuseActive = ref(false)
const fuseRunning = ref(false)
const currentFuseMs = ref(600)
const nextLevel = ref(null)
const ignitedSegmentIdx = ref(null)
let fuseTimer = null

// fuse bar hover
const hoveredSegmentIdx = ref(null)

// overlays
const showHelp = ref(false)
const pendingExtensionItem = ref(null)
const newOtuName = ref(null) // non-null string when the !n OTU create modal is open
let preventBlur = false // mirrors Autocomplete.vue pattern

// ── Computed ───────────────────────────────────────────────────────────────────
const fuseSegments = computed(() =>
  (config.value?.levels ?? []).map((l) => ({
    key: String(l.key),
    label: l.label,
    description: l.description,
    external: l.external ?? false,
    fuse_ms: l.fuse_ms ?? 600
  }))
)

const visibleOperators = computed(() =>
  getOperators().filter((op) => !op.client_only)
)

const currentSpinner = computed(
  () => LEVEL_SPINNERS[currentLevel.value] ?? TaxonWorksSpinner
)

const currentLevelSegment = computed(() =>
  fuseSegments.value.find((s) => s.key === String(currentLevel.value))
)

const spinnerTitle = computed(() => {
  const seg = currentLevelSegment.value
  return seg?.external ? `Searching ${seg.label}...` : 'Searching...'
})

// ── Lifecycle ──────────────────────────────────────────────────────────────────
onMounted(async () => {
  await fetchConfig()
  currentLevel.value = getFirstLevelKey()
  ready.value = true
  window.addEventListener('resize', updateDropdownPosition)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateDropdownPosition)
})

// ── Level operator detection (!1, !2 …) ───────────────────────────────────────
// Scans anywhere in the string for !N (e.g. "Foo !1", "!2 Bar", "Homo !3 sapiens").
// Returns { levelKey, cleanTerm } with the operator and surrounding whitespace stripped.
function detectLevelOperator(text) {
  const match = text.match(/^(.*?)!(\d+)\s*(.*)$/)
  if (!match) return null
  const n = parseInt(match[2], 10) - 1 // !1 → index 0
  const segs = fuseSegments.value
  if (n < 0 || n >= segs.length) return null
  const cleanTerm = (match[1] + match[3]).replace(/\s+/g, ' ').trim()
  return { levelKey: segs[n].key, cleanTerm }
}

// ── Input handler ──────────────────────────────────────────────────────────────
function onInput() {
  const text = inputText.value

  if (!text.trim()) {
    clearResults()
    cancelFuse()
    return
  }

  // !? — show help, don't search
  if (/^!\?/.test(text)) {
    showHelp.value = true
    return
  }

  // !n — create new record; detectable anywhere in the string (e.g. "zzz !n")
  // Strip the operator (and surrounding spaces) to get the name prefill.
  const newRecordMatch = text.match(/^(.*?)\s*!n\s*(.*)$/i)
  if (newRecordMatch !== null) {
    const cleanName = (newRecordMatch[1] + ' ' + newRecordMatch[2]).replace(/\s+/g, ' ').trim()
    inputText.value = cleanName
    cancelFuse()
    if (getRequest) clearTimeout(getRequest)
    clearResults()
    newOtuName.value = cleanName
    return
  }

  // !1, !2 … — jump to level, strip operator
  // Jumping backward never fires a search (user may still be composing the term).
  // Jumping forward only searches if there is a clean term; otherwise just clear.
  const levelOp = detectLevelOperator(text)
  if (levelOp !== null) {
    currentLevel.value = levelOp.levelKey
    inputText.value = levelOp.cleanTerm
    cancelFuse()
    if (getRequest) clearTimeout(getRequest)

    if (levelOp.cleanTerm.length === 0) {
      clearResults()
    } else {
      triggerSearch(levelOp.cleanTerm)
    }
    return
  }

  // Normal keypress — reset fuse to current level (frozen until next no-result)
  if (fuseActive.value) {
    cancelFuse()
  }

  // Debounce, matching Autocomplete.vue's checkTime() pattern
  current.value = -1
  searchEnd.value = false
  if (getRequest) clearTimeout(getRequest)
  getRequest = setTimeout(() => {
    triggerSearch(text)
  }, props.levelDelay)
}

// ── Search ─────────────────────────────────────────────────────────────────────
function triggerSearch(term) {
  if (!term || term.trim() === '') return

  controller.value?.abort()
  controller.value = new AbortController()
  isSearching.value = true
  dropdownItems.value = []

  AjaxCall('get', props.url, {
    params: { term, level: currentLevel.value },
    signal: controller.value.signal
  })
    .then(({ body }) => {
      if (!body) return
      const results = body.response ?? []
      dropdownItems.value = results
      showList.value = true
      searchEnd.value = true
      current.value = -1
      nextTick(updateDropdownPosition)

      // Light fuse only when search completes with zero results and there is a next level
      if (results.length === 0 && body.next_level) {
        lightFuse(body.next_level)
      }
    })
    .catch(() => {})
    .finally(() => {
      isSearching.value = false
    })
}

// ── Dropdown positioning (mirrors Autocomplete.vue) ───────────────────────────
function updateDropdownPosition() {
  nextTick(() => {
    const input = inputEl.value
    const dropdown = dropdownEl.value
    if (!input || !dropdown) return

    const rect = input.getBoundingClientRect()
    const viewportHeight = window.innerHeight
    const viewportWidth = window.innerWidth
    const spaceBelow = viewportHeight - rect.bottom
    const spaceAbove = rect.top
    const showAbove = spaceBelow < 150 && spaceAbove > spaceBelow
    const maxWidth = viewportWidth - rect.left - 32
    const maxHeight = Math.min(
      showAbove ? spaceAbove - 12 : spaceBelow - 12,
      500
    )

    dropdown.style.maxHeight = maxHeight + 'px'
    dropdown.style.minWidth = rect.width + 'px'
    dropdown.style.maxWidth = maxWidth + 'px'

    const items = dropdown.querySelectorAll('li')
    const contentWidth = Array.from(items).reduce(
      (acc, li) => Math.max(acc, li.scrollWidth),
      0
    )
    const finalWidth = Math.min(contentWidth + 20, maxWidth)
    const dropdownH = dropdown.offsetHeight || maxHeight
    const top = showAbove
      ? rect.top + window.scrollY - dropdownH - 6
      : rect.bottom + window.scrollY + 2
    const left = rect.left + window.scrollX

    dropdownStyle.value = {
      top: `${Math.max(top, 0)}px`,
      left: `${Math.max(left, 0)}px`,
      width: finalWidth + 'px',
      minWidth: rect.width + 'px',
      maxWidth: maxWidth + 'px'
    }
  })
}

// ── Fuse mechanic ──────────────────────────────────────────────────────────────
// The ignition sweeps across the *current* (departing) segment while we wait to escalate
// to targetLevel.  Fuse duration comes from the departing segment's position in the stack,
// not from the target level's intrinsic type, so that user-reordered stacks behave correctly.
function lightFuse(targetLevel) {
  if (!targetLevel) return

  const currentIdx = fuseSegments.value.findIndex(
    (s) => s.key === String(currentLevel.value)
  )
  const departingSeg = fuseSegments.value[currentIdx]

  nextLevel.value = targetLevel
  currentFuseMs.value = departingSeg?.fuse_ms ?? 600
  ignitedSegmentIdx.value = currentIdx // animate the departing segment
  fuseActive.value = true

  nextTick(() => {
    fuseRunning.value = true
  })

  fuseTimer = setTimeout(() => {
    escalateToLevel(targetLevel)
  }, currentFuseMs.value)
}

function cancelFuse() {
  clearTimeout(fuseTimer)
  fuseActive.value = false
  fuseRunning.value = false
  nextLevel.value = null
  ignitedSegmentIdx.value = null
}

function escalateToLevel(level) {
  currentLevel.value = level
  cancelFuse()
  clearResults()
  if (inputText.value.trim()) {
    triggerSearch(inputText.value)
  }
}

// Clicking a fuse segment: jump directly to that level
function onFuseSegmentClick(seg, idx) {
  // Only allow jumping forward from current level (no going back)
  const currentIdx = fuseSegments.value.findIndex(
    (s) => s.key === currentLevel.value
  )
  if (idx <= currentIdx) return
  escalateToLevel(seg.key)
}

// ── Item selection ─────────────────────────────────────────────────────────────
function itemClicked(idx) {
  const item = dropdownItems.value[idx]
  if (!item) return

  showList.value = false
  cancelFuse()

  if (item.extension && Object.keys(item.extension).length > 0) {
    pendingExtensionItem.value = item
    return
  }
  completeSelection(item)
}

function completeSelection(item) {
  inputText.value = item.label ?? ''
  emit('update:modelValue', item)
  emit('select', item.response_values)
  pendingExtensionItem.value = null
}

function confirmExtension() {
  if (pendingExtensionItem.value) completeSelection(pendingExtensionItem.value)
}

function cancelExtension() {
  pendingExtensionItem.value = null
  nextTick(() => inputEl.value?.focus())
}

function onColConfirm(taxonNameId) {
  completeSelection({
    id: taxonNameId,
    label: pendingExtensionItem.value.label,
    label_html: pendingExtensionItem.value.label_html,
    info: '',
    response_values: { taxon_name_id: taxonNameId },
    extension: {}
  })
}

function onOtuCreated({ otuId, otuName: createdName }) {
  newOtuName.value = null
  completeSelection({
    id: otuId,
    label: createdName,
    label_html: createdName,
    info: '',
    response_values: { otu_id: otuId },
    extension: {}
  })
}

function cancelOtuNew() {
  newOtuName.value = null
  nextTick(() => inputEl.value?.focus())
}

// ── Keyboard navigation ────────────────────────────────────────────────────────
function moveSelection(delta) {
  if (!showList.value) return
  const max = dropdownItems.value.length - 1
  if (max < 0) return
  current.value = Math.max(0, Math.min(max, current.value + delta))
  scrollToActive()
}

function scrollToActive() {
  nextTick(() => {
    const dropdown = dropdownEl.value
    if (!dropdown) return
    const items = dropdown.querySelectorAll('li')
    const activeEl = items[current.value]
    if (!activeEl) return
    const dRect = dropdown.getBoundingClientRect()
    const iRect = activeEl.getBoundingClientRect()
    if (iRect.bottom > dRect.bottom)
      dropdown.scrollTop += iRect.bottom - dRect.bottom
    else if (iRect.top < dRect.top) dropdown.scrollTop -= dRect.top - iRect.top
  })
}

function confirmHighlighted() {
  if (current.value >= 0 && dropdownItems.value[current.value]) {
    itemClicked(current.value)
  }
}

function onEscape() {
  showList.value = false
  cancelFuse()
}

// ── Focus / blur — mirrors Autocomplete.vue ────────────────────────────────────
function onFocus() {
  if (searchEnd.value) showList.value = true
}

function onBlur() {
  if (preventBlur) {
    preventBlur = false
    return
  }
  showList.value = false
  current.value = -1
}

function onDropdownMousedown() {
  preventBlur = true
}

// ── Helpers ────────────────────────────────────────────────────────────────────
function clearResults() {
  dropdownItems.value = []
  showList.value = false
  searchEnd.value = false
}
</script>

<style scoped>
.autoselect-field {
  position: relative;
  width: 100%;
}

/* ── Fuse track ── */
.autoselect-field__fuse-track {
  display: flex;
  align-items: flex-end;
  width: 100%;
  height: 8px;
  gap: 2px;
  margin-bottom: 3px;
}

.autoselect-field__fuse-segment {
  flex: 1;
  position: relative;
  height: 5px;
  border-radius: 3px;
  cursor: pointer;
  overflow: visible;
  transition:
    flex 0.25s ease,
    height 0.25s ease;
}

.autoselect-field__fuse-segment:hover {
  flex: 2;
}

/* Active segment (currently being searched) is 3px taller */
.autoselect-field__fuse-segment--active {
  height: 8px;
}

.autoselect-field__fuse-segment--internal {
  background: #c8c0b8;
}

.autoselect-field__fuse-segment--external {
  background: #6da8d4;
}

.autoselect-field__fuse-ignition {
  position: absolute;
  inset: 0;
  border-radius: 3px;
  width: 0%;
  background: #e07832;
  transition-property: width;
  transition-timing-function: linear;
}

.autoselect-field__fuse-ignition--running {
  width: 100%;
}

.autoselect-field__fuse-tooltip {
  position: absolute;
  top: calc(100% + 4px);
  left: 50%;
  transform: translateX(-50%);
  z-index: 10001;
  background: var(--panel-bg-color, #fff);
  border: 1px solid var(--border-color, #ccc);
  border-radius: 4px;
  padding: 5px 10px;
  white-space: nowrap;
  font-size: 11px;
  line-height: 1.5;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
  display: flex;
  flex-direction: column;
  gap: 1px;
  pointer-events: none;
}

.autoselect-field__fuse-tooltip-trigger {
  font-family: monospace;
  color: #e07832;
  font-weight: 700;
}

.autoselect-field__fuse-tooltip-label {
  font-weight: 600;
  color: var(--text-color, #333);
}

.autoselect-field__fuse-tooltip-desc {
  color: var(--text-color-muted, #666);
}

/* ── Input row ── */
.autoselect-field__input-wrap {
  position: relative;
}

.autoselect-field__input {
  width: 100%;
  padding-right: 26px;
  box-sizing: border-box;
}

.autoselect-field__input-spinner {
  position: absolute;
  right: 6px;
  top: 50%;
  transform: translateY(-50%);
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 14px;
  line-height: 1;
  pointer-events: none;
  user-select: none;
}

/* ── Dropdown (teleported to body, matches vue-autocomplete-list styling) ── */
.autoselect-field__dropdown {
  position: absolute;
  display: block;
  max-height: 500px;
  overflow-y: auto;
  overflow-x: hidden;
  z-index: 9998;
  background-color: var(--panel-bg-color);
  margin: 0;
  padding: 0;
  list-style: none;
  border: 1px solid var(--border-color);
  border-top: none;
  border-bottom: 4px solid var(--border-color);
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.2);
  box-sizing: border-box;
  min-width: 100%;
}

.autoselect-field__dropdown-item {
  cursor: pointer;
  padding: 6px 12px;
  border-top: 1px solid var(--border-color);
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 8px;
  font-size: 12px;
}

.autoselect-field__dropdown-item--active {
  background-color: var(--border-color);
}

.autoselect-field__item-info {
  font-size: 10px;
  opacity: 0.7;
  white-space: nowrap;
}

.autoselect-field__dropdown-none {
  padding: 6px 12px;
  border-top: 1px solid var(--border-color);
  font-size: 12px;
  color: var(--text-color-muted, #888);
}

/* ── Help overlay ── */
.autoselect-field__help-overlay {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 9999;
  background: var(--panel-bg-color, #fff);
  border: 1px solid var(--border-color, #ccc);
  padding: var(--standard-padding, 8px);
  border-radius: 3px;
  font-size: 12px;
  box-shadow: 0 2px 6px rgba(0, 0, 0, 0.15);
}

.autoselect-field__help-overlay h4 {
  margin: 0 0 6px;
  font-size: 13px;
}

.autoselect-field__help-overlay ul {
  margin: 0 0 8px;
  padding-left: 16px;
}

</style>
