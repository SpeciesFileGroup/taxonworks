<template>
  <div
    :id="effectiveId"
    class="autoselect"
  >
    <!-- Fuse bar — segmented, above input; hidden levels are not rendered -->
    <div class="autoselect__fuse-track">
      <div
        v-for="(seg, idx) in visibleFuseSegments"
        :key="seg.key"
        class="autoselect__fuse-segment"
        :class="[
          seg.external
            ? 'autoselect__fuse-segment--external'
            : 'autoselect__fuse-segment--internal',
          {
            'autoselect__fuse-segment--ignited': ignitedSegmentKey === seg.key
          },
          {
            'autoselect__fuse-segment--active': seg.key === currentLevel
          }
        ]"
        @click="onFuseSegmentClick(seg, idx)"
        @mouseenter="hoveredSegmentIdx = idx"
        @mouseleave="hoveredSegmentIdx = null"
      >
        <!-- Orange ignition sweep -->
        <div
          v-if="ignitedSegmentKey === seg.key"
          class="autoselect__fuse-ignition"
          :style="{ transitionDuration: currentFuseMs + 'ms' }"
          :class="{ 'autoselect__fuse-ignition--running': fuseRunning }"
        />

        <!-- Hover tooltip -->
        <div
          v-if="hoveredSegmentIdx === idx"
          class="autoselect__fuse-tooltip"
        >
          <span class="autoselect__fuse-tooltip-trigger">!{{ idx + 1 }}</span>
          <span class="autoselect__fuse-tooltip-label">{{ seg.displayLabel }}</span>
          <span class="autoselect__fuse-tooltip-desc">{{ seg.description }}</span>
        </div>
      </div>
    </div>

    <!-- Input with inline spinner -->
    <div class="autoselect__input-wrap">
      <input
        ref="inputEl"
        type="text"
        class="autoselect__input normal-input"
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
        class="autoselect__input-spinner"
        :title="spinnerTitle"
      >
        <component :is="currentSpinner" />
      </span>
    </div>

    <!-- Dropdown — visible only after a search completes -->
    <teleport to="body">
      <ul
        v-if="showList && searchEnd"
        v-show="showList"
        class="autoselect__dropdown"
        ref="dropdownEl"
        :style="dropdownStyle"
        @mousedown="onDropdownMousedown"
      >
        <template v-if="dropdownItems.length">
          <li
            v-for="(item, idx) in dropdownItems"
            :key="item.id ?? 'item-' + idx"
            class="autoselect__dropdown-item"
            :class="{ 'autoselect__dropdown-item--active': idx === current }"
            @mouseover="current = idx"
            @click.prevent="itemClicked(idx)"
          >
            <span v-html="item.label_html || item.label" />
            <span
              v-if="item.info_html && showInfo"
              class="autoselect__item-info"
              v-html="item.info_html"
            />
          </li>
        </template>
        <li
          v-else
          class="autoselect__dropdown-none"
        >
          --None--
        </li>
      </ul>
    </teleport>

    <!-- Help overlay (!?) -->
    <div
      v-if="showHelp"
      class="autoselect__help-overlay"
    >
      <button
        class="autoselect__help-close"
        title='Use "Esc" to close'
        @click="closeHelp"
      >&#x2715;</button>
      <h4>Available operators</h4>
      <ul class="autoselect__help-list">
        <li
          v-for="op in sortedOperators"
          :key="op.trigger"
          class="autoselect__help-item"
        >
          <template v-if="isOperatorLinkable(op)">
            <button
              ref="helpItemEls"
              class="autoselect__help-btn"
              @click="fireOperator(op)"
              @keydown.up.prevent="moveHelpFocus(-1)"
              @keydown.down.prevent="moveHelpFocus(1)"
              @keydown.enter.prevent="fireOperator(op)"
              @keydown.escape.prevent="closeHelp"
            ><code>{{ op.trigger }}</code></button>
          </template>
          <code v-else>{{ op.trigger }}</code>
          <span class="autoselect__help-desc"> — {{ op.description }}</span>
        </li>
      </ul>
    </div>

    <!-- CoL confirmation modal -->
    <Teleport to="body">
      <ColConfirmModal
        v-if="pendingExtensionItem?.extension?.col_key"
        :item="pendingExtensionItem"
        @confirm="onColConfirm"
        @cancel="cancelExtension"
      />
    </Teleport>

    <!-- New-record modal (!n) -->
    <Teleport to="body">
      <component
        :is="newRecordComponent"
        v-if="newRecordName !== null && newRecordComponent !== null"
        :name-prefill="newRecordName"
        @confirm="onNewRecordCreated"
        @cancel="cancelNewRecord"
      />
    </Teleport>

    <!-- Preferences modal (!p) -->
    <Teleport to="body">
      <PreferencesModal
        v-if="showPreferences"
        :levels="allFuseSegments"
        :current-prefs="prefs.getPrefs()"
        :options-component="preferencesOptionsComponent"
        @save="onPrefsSave"
        @cancel="cancelPreferences"
      />
    </Teleport>
  </div>
</template>

<script setup>
import { ref, computed, watch, onMounted, onBeforeUnmount, nextTick } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { useAutoselect } from '@/components/ui/AutoselectField/useAutoselect'
import { usePreferences } from '@/components/ui/AutoselectField/usePreferences'
import ColConfirmModal from '@/components/ui/AutoselectField/ColConfirmModal.vue'
import PreferencesModal from '@/components/ui/AutoselectField/PreferencesModal.vue'
import CatalogueOfLifeSpinner from '@/components/ui/AutoselectField/CatalogueOfLifeSpinner.vue'
import TaxonWorksSpinner from '@/components/ui/AutoselectField/TaxonWorksSpinner.vue'

const LEVEL_SPINNERS = {
  catalogue_of_life: CatalogueOfLifeSpinner
}

// ── Props & emits ──────────────────────────────────────────────────────────────
const props = defineProps({
  url: { type: String, required: true },
  modelValue: { type: Object, default: null },
  param: { type: String, required: true },
  placeholder: { type: String, default: 'Search...' },
  disabled: { type: Boolean, default: false },
  levelDelay: { type: Number, default: 500 },
  // Unique identifier for this autoselect instance.
  // Used as the root div id and as the preferences storage key.
  // When omitted a UUID is generated automatically.
  id: { type: String, default: null },
  // Vue component to render when !n is triggered (null = disabled).
  newRecordComponent: { type: Object, default: null },
  // Vue component rendered inside PreferencesModal for model-specific options (null = none).
  preferencesOptionsComponent: { type: Object, default: null }
})

const emit = defineEmits(['update:modelValue', 'select'])

// ── Effective id (prop or UUID) ────────────────────────────────────────────────
const effectiveId = props.id ?? `autoselect_${crypto.randomUUID()}`

// ── Composables ────────────────────────────────────────────────────────────────
const { config, fetchConfig, getFirstLevelKey, getOperators } =
  useAutoselect(props.url)

const prefs = usePreferences(props.url, effectiveId)

// ── Reactive preferences state ─────────────────────────────────────────────────
// A reactive snapshot of the current prefs so computed labels re-derive on save.
const currentPrefs = ref(prefs.getPrefs())

// ── Refs ───────────────────────────────────────────────────────────────────────
const inputEl = ref(null)
const dropdownEl = ref(null)

const ready = ref(false)
const inputText = ref('')
const currentLevel = ref(null)
const dropdownItems = ref([])
const current = ref(-1)
const isSearching = ref(false)
const searchEnd = ref(false)
const showList = ref(false)
const dropdownStyle = ref({})
const controller = ref(null)
let getRequest = 0

// fuse state
const fuseActive = ref(false)
const fuseRunning = ref(false)
const currentFuseMs = ref(600)
const nextLevel = ref(null)
const ignitedSegmentKey = ref(null)  // keyed by level key, not index
let fuseTimer = null

const hoveredSegmentIdx = ref(null)

// overlays
const showHelp = ref(false)
const showPreferences = ref(false)
const helpItemEls = ref([])
const pendingExtensionItem = ref(null)
const newRecordName = ref(null)
let preventBlur = false
let preInputText = '' // text in field before !p was typed

// ── All segments (before preference filtering) ─────────────────────────────────
const allFuseSegments = computed(() =>
  (config.value?.levels ?? []).map((l) => {
    const key = String(l.key)
    const options = currentPrefs.value.levels?.[key]?.options || {}
    const displayLabel = options.dataset_title
      ? `${l.label} (${options.dataset_title})`
      : l.label
    return {
      key,
      label: l.label,
      displayLabel,
      description: l.description,
      external: l.external ?? false,
      fuse_ms: l.fuse_ms ?? 600
    }
  })
)

// Segments visible after applying preferences (hide flag)
const visibleFuseSegments = computed(() =>
  allFuseSegments.value.filter((s) => prefs.isLevelVisible(s.key))
)

// Help operator moved to bottom; !N is a pattern placeholder (not directly invokable)
const sortedOperators = computed(() => {
  const ops = getOperators()
  const help = ops.find((op) => op.key === 'help')
  const rest = ops.filter((op) => op.key !== 'help')
  return help ? [...rest, help] : ops
})

function isOperatorLinkable(op) {
  if (op.key === 'help' || op.key === 'level_number') return false
  if (op.key === 'new_record' && props.newRecordComponent === null) return false
  return true
}

const showInfo = computed(() => currentPrefs.value.show_info !== false)

const currentSpinner = computed(
  () => LEVEL_SPINNERS[currentLevel.value] ?? TaxonWorksSpinner
)

const currentLevelSegment = computed(() =>
  visibleFuseSegments.value.find((s) => s.key === String(currentLevel.value))
)

const spinnerTitle = computed(() => {
  const seg = currentLevelSegment.value
  return seg?.external ? `Searching ${seg.displayLabel}...` : 'Searching...'
})

// ── Lifecycle ──────────────────────────────────────────────────────────────────
onMounted(async () => {
  await fetchConfig()
  currentLevel.value = getFirstVisibleLevelKey()
  ready.value = true
  window.addEventListener('resize', updateDropdownPosition)
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', updateDropdownPosition)
})

// ── Level helpers ──────────────────────────────────────────────────────────────
function getFirstVisibleLevelKey() {
  return visibleFuseSegments.value[0]?.key ?? getFirstLevelKey()
}

function detectLevelOperator(text) {
  const match = text.match(/^(.*?)!(\d+)\s*(.*)$/)
  if (!match) return null
  const n = parseInt(match[2], 10) - 1
  const segs = visibleFuseSegments.value
  if (n < 0 || n >= segs.length) return null
  const cleanTerm = (match[1] + match[3]).replace(/\s+/g, ' ').trim()
  return { levelKey: segs[n].key, cleanTerm }
}

function firstExternalLevelKey() {
  const seg = visibleFuseSegments.value.find((s) => s.external)
  return seg?.key ?? null
}

// Next visible level after currentKey
function nextVisibleLevelKey(currentKey) {
  const segs = visibleFuseSegments.value
  const idx = segs.findIndex((s) => s.key === String(currentKey))
  if (idx < 0 || idx >= segs.length - 1) return null
  return segs[idx + 1].key
}

// ── Input handler ──────────────────────────────────────────────────────────────
function onInput() {
  const text = inputText.value

  if (!text.trim()) {
    clearResults()
    cancelFuse()
    return
  }

  if (/^!\s*$/.test(text)) {
    cancelFuse()
    if (getRequest) clearTimeout(getRequest)
    return
  }

  // !? — help overlay (may appear anywhere in the string, like other operators)
  const helpMatch = text.match(/^(.*?)\s*!\?\s*(.*)$/)
  if (helpMatch !== null) {
    inputText.value = (helpMatch[1] + ' ' + helpMatch[2]).replace(/\s+/g, ' ').trim()
    showHelp.value = true
    return
  }

  // !p — preferences modal
  const prefMatch = text.match(/^(.*?)\s*!p\s*(.*)$/i)
  if (prefMatch !== null) {
    preInputText = (prefMatch[1] + ' ' + prefMatch[2]).replace(/\s+/g, ' ').trim()
    inputText.value = preInputText
    cancelFuse()
    if (getRequest) clearTimeout(getRequest)
    clearResults()
    showPreferences.value = true
    return
  }

  // !i — toggle info display
  const infoMatch = text.match(/^(.*?)\s*!i\s*(.*)$/i)
  if (infoMatch !== null) {
    const cleanTerm = (infoMatch[1] + ' ' + infoMatch[2]).replace(/\s+/g, ' ').trim()
    inputText.value = cleanTerm
    prefs.toggleShowInfo()
    currentPrefs.value = prefs.getPrefs()
    return
  }

  // !n — new record modal
  const newRecordMatch = text.match(/^(.*?)\s*!n\s*(.*)$/i)
  if (newRecordMatch !== null && props.newRecordComponent !== null) {
    const cleanName = (newRecordMatch[1] + ' ' + newRecordMatch[2]).replace(/\s+/g, ' ').trim()
    inputText.value = cleanName
    cancelFuse()
    if (getRequest) clearTimeout(getRequest)
    clearResults()
    newRecordName.value = cleanName
    return
  }

  // !e — jump to leftmost external level
  const externalMatch = text.match(/^(.*?)\s*!e\s*(.*)$/i)
  if (externalMatch !== null) {
    const externalKey = firstExternalLevelKey()
    if (externalKey !== null) {
      const cleanTerm = (externalMatch[1] + ' ' + externalMatch[2]).replace(/\s+/g, ' ').trim()
      inputText.value = cleanTerm
      currentLevel.value = externalKey
      cancelFuse()
      if (getRequest) clearTimeout(getRequest)
      if (cleanTerm.length === 0) clearResults()
      else triggerSearch(cleanTerm)
      return
    }
  }

  // !1, !2 … — jump to visible level
  const levelOp = detectLevelOperator(text)
  if (levelOp !== null) {
    currentLevel.value = levelOp.levelKey
    inputText.value = levelOp.cleanTerm
    cancelFuse()
    if (getRequest) clearTimeout(getRequest)
    if (levelOp.cleanTerm.length === 0) clearResults()
    else triggerSearch(levelOp.cleanTerm)
    return
  }

  if (fuseActive.value) cancelFuse()

  current.value = -1
  searchEnd.value = false
  if (getRequest) clearTimeout(getRequest)
  getRequest = setTimeout(() => triggerSearch(text), props.levelDelay)
}

// ── Search ─────────────────────────────────────────────────────────────────────
function triggerSearch(term) {
  if (!term || term.trim() === '') return

  controller.value?.abort()
  controller.value = new AbortController()
  isSearching.value = true
  dropdownItems.value = []

  // Merge current level's preference options and global prefs into the request params
  const levelOptions = prefs.getLevelOptions(currentLevel.value)

  AjaxCall('get', props.url, {
    params: { term, level: currentLevel.value, ...levelOptions, show_info: prefs.getShowInfo() },
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

      if (results.length === 0 && body.next_level) {
        // Only light fuse to the next visible level
        const nextVisible = nextVisibleLevelKey(currentLevel.value)
        if (nextVisible) lightFuse(nextVisible)
      }
    })
    .catch(() => {})
    .finally(() => {
      isSearching.value = false
    })
}

// ── Dropdown positioning ───────────────────────────────────────────────────────
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
function lightFuse(targetLevel) {
  if (!targetLevel) return

  const seg = visibleFuseSegments.value.find((s) => s.key === String(currentLevel.value))

  nextLevel.value = targetLevel
  currentFuseMs.value = seg?.fuse_ms ?? 600
  ignitedSegmentKey.value = String(currentLevel.value)
  fuseActive.value = true

  nextTick(() => { fuseRunning.value = true })

  fuseTimer = setTimeout(() => {
    escalateToLevel(targetLevel)
  }, currentFuseMs.value)
}

function cancelFuse() {
  clearTimeout(fuseTimer)
  fuseActive.value = false
  fuseRunning.value = false
  nextLevel.value = null
  ignitedSegmentKey.value = null
}

function escalateToLevel(level) {
  currentLevel.value = level
  cancelFuse()
  clearResults()
  if (inputText.value.trim()) triggerSearch(inputText.value)
}

function onFuseSegmentClick(seg, idx) {
  const currentIdx = visibleFuseSegments.value.findIndex(
    (s) => s.key === currentLevel.value
  )
  if (idx === currentIdx) return
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

function cancelExtension() {
  pendingExtensionItem.value = null
  nextTick(() => inputEl.value?.focus())
}

function onColConfirm(createdId) {
  const yieldsKey = pendingExtensionItem.value.extension?.hook?.yields ?? 'taxon_name_id'
  completeSelection({
    id: createdId,
    label: pendingExtensionItem.value.label,
    label_html: pendingExtensionItem.value.label_html,
    info: '',
    response_values: { [yieldsKey]: createdId },
    extension: {}
  })
}

function onNewRecordCreated(item) {
  newRecordName.value = null
  completeSelection(item)
}

function cancelNewRecord() {
  newRecordName.value = null
  nextTick(() => inputEl.value?.focus())
}

// ── Preferences modal (!p) ─────────────────────────────────────────────────────
function onPrefsSave(updatedPrefs) {
  prefs.savePrefs(updatedPrefs)
  currentPrefs.value = updatedPrefs
  showPreferences.value = false
  // If the current level was hidden, jump to the first still-visible level
  if (!prefs.isLevelVisible(currentLevel.value)) {
    currentLevel.value = getFirstVisibleLevelKey()
  }
  // Reset search state so the field re-runs with the new preferences applied
  clearResults()
  cancelFuse()
  const term = inputText.value.trim()
  nextTick(() => {
    inputEl.value?.focus()
    if (term) triggerSearch(term)
  })
}

function cancelPreferences() {
  showPreferences.value = false
  nextTick(() => inputEl.value?.focus())
}

// Focus the first linkable operator button when the help overlay opens
watch(showHelp, (val) => {
  if (val) nextTick(() => helpItemEls.value[0]?.focus())
})

function closeHelp() {
  showHelp.value = false
  nextTick(() => {
    const el = inputEl.value
    if (!el) return
    el.focus()
    const len = el.value.length
    el.setSelectionRange(len, len)
  })
}

// Fire an operator from the help list: close overlay, inject trigger, run onInput
function fireOperator(op) {
  showHelp.value = false
  inputText.value = op.trigger
  onInput()
  // Modal-opening operators manage their own focus; search operators need input focus
  if (op.key !== 'new_record' && op.key !== 'preferences') {
    nextTick(() => inputEl.value?.focus())
  }
}

function moveHelpFocus(delta) {
  const btns = helpItemEls.value.filter(Boolean)
  const idx = btns.indexOf(document.activeElement)
  btns[Math.max(0, Math.min(btns.length - 1, idx + delta))]?.focus()
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
    if (iRect.bottom > dRect.bottom) dropdown.scrollTop += iRect.bottom - dRect.bottom
    else if (iRect.top < dRect.top) dropdown.scrollTop -= dRect.top - iRect.top
  })
}

function confirmHighlighted() {
  if (current.value >= 0 && dropdownItems.value[current.value]) {
    itemClicked(current.value)
  }
}

function onEscape() {
  if (showHelp.value) {
    closeHelp()
    return
  }
  showList.value = false
  cancelFuse()
}

// ── Focus / blur ───────────────────────────────────────────────────────────────
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
.autoselect {
  position: relative;
  width: 100%;
}

/* ── Fuse track ── */
.autoselect__fuse-track {
  display: flex;
  align-items: flex-end;
  width: 100%;
  height: 8px;
  gap: 2px;
  margin-bottom: 3px;
}

.autoselect__fuse-segment {
  flex: 1;
  position: relative;
  height: 5px;
  border-radius: 3px;
  cursor: pointer;
  overflow: visible;
  transition: flex 0.25s ease, height 0.25s ease;
}

.autoselect__fuse-segment:hover {
  flex: 2;
}

.autoselect__fuse-segment--active {
  height: 8px;
}

.autoselect__fuse-segment--internal {
  background: #c8c0b8;
}

.autoselect__fuse-segment--external {
  background: #6da8d4;
}

.autoselect__fuse-ignition {
  position: absolute;
  inset: 0;
  border-radius: 3px;
  width: 0%;
  background: #e07832;
  transition-property: width;
  transition-timing-function: linear;
}

.autoselect__fuse-ignition--running {
  width: 100%;
}

.autoselect__fuse-tooltip {
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

.autoselect__fuse-tooltip-trigger {
  font-family: monospace;
  color: #e07832;
  font-weight: 700;
}

.autoselect__fuse-tooltip-label {
  font-weight: 600;
  color: var(--text-color, #333);
}

.autoselect__fuse-tooltip-desc {
  color: var(--text-color-muted, #666);
}

/* ── Input row ── */
.autoselect__input-wrap {
  position: relative;
}

.autoselect__input {
  width: 100%;
  padding-right: 26px;
  box-sizing: border-box;
}

.autoselect__input-spinner {
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

/* ── Dropdown ── */
.autoselect__dropdown {
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

.autoselect__dropdown-item {
  cursor: pointer;
  padding: 6px 12px;
  border-top: 1px solid var(--border-color);
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 8px;
  font-size: 12px;
}

.autoselect__dropdown-item--active {
  background-color: var(--border-color);
}

.autoselect__item-info {
  font-size: 10px;
  opacity: 0.7;
  white-space: nowrap;
}

.autoselect__dropdown-none {
  padding: 6px 12px;
  border-top: 1px solid var(--border-color);
  font-size: 12px;
  color: var(--text-color-muted, #888);
}

/* ── Help overlay ── */
.autoselect__help-overlay {
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

.autoselect__help-close {
  position: absolute;
  top: 5px;
  right: 6px;
  background: none;
  border: none;
  cursor: pointer;
  font-size: 13px;
  line-height: 1;
  color: var(--text-color-muted, #888);
  padding: 0 2px;
}

.autoselect__help-close:hover {
  color: var(--color-destroy, #c00);
}

.autoselect__help-overlay h4 {
  margin: 0 0 6px;
  font-size: 13px;
  padding-right: 18px;
}

.autoselect__help-list {
  list-style: none;
  margin: 0;
  padding: 0;
  display: flex;
  flex-direction: column;
  gap: 2px;
}

.autoselect__help-item {
  display: flex;
  align-items: baseline;
  gap: 4px;
}

.autoselect__help-btn {
  background: none;
  border: 1px solid transparent;
  border-radius: 2px;
  padding: 0 1px;
  cursor: pointer;
  line-height: 1;
  font-size: inherit;
}

.autoselect__help-btn:hover,
.autoselect__help-btn:focus {
  border-color: var(--color-primary, #2563eb);
  outline: none;
}

.autoselect__help-desc {
  color: var(--text-color, #333);
}
</style>
