<template>
  <div class="autoselect-field">
    <!-- Input row -->
    <div class="autoselect-field__input-row">
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
        @keydown.escape="closeDropdown"
        @focus="onFocus"
        @blur="onBlur"
      />
      <span
        v-if="isSearching"
        class="autoselect-field__spinner"
        :title="isExternalLevel(currentLevel) ? 'Searching external sources...' : 'Searching...'"
      >
        {{ isExternalLevel(currentLevel) ? '&#127760;' : '&#8987;' }}
      </span>
    </div>

    <!-- Fuse progress bar -->
    <div
      v-if="fuseActive"
      class="autoselect-field__fuse-bar"
      :title="`Auto-escalating to ${nextLevel} in ${currentFuseMs}ms — click to search now`"
      @click="triggerEscalation"
    >
      <div
        class="autoselect-field__fuse-fill"
        :style="{ transitionDuration: currentFuseMs + 'ms' }"
        :class="{ 'autoselect-field__fuse-fill--running': fuseRunning }"
      />
    </div>

    <!-- Dropdown -->
    <ul
      v-if="showDropdown && dropdownItems.length > 0"
      class="autoselect-field__dropdown"
      ref="dropdownEl"
    >
      <li
        v-for="(item, idx) in dropdownItems"
        :key="item.id ?? idx"
        class="autoselect-field__dropdown-item"
        :class="{ 'autoselect-field__dropdown-item--highlighted': idx === highlightedIndex }"
        @mousedown.prevent="selectItem(item)"
        @mouseover="highlightedIndex = idx"
      >
        <span class="autoselect-field__item-label" v-html="item.label_html || item.label" />
        <span v-if="item.info" class="autoselect-field__item-info">{{ item.info }}</span>
      </li>
    </ul>

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
      <button class="autoselect-field__help-close btn" @click="showHelp = false">Close</button>
    </div>

    <!-- Extension panel: CoL alignment or new-OTU form -->
    <div
      v-if="pendingExtensionItem"
      class="autoselect-field__extension-panel"
    >
      <!-- New OTU form sentinel -->
      <template v-if="pendingExtensionItem.extension?.mode === 'new_otu_form'">
        <p><strong>Create new OTU</strong></p>
        <p>Name: <em>{{ pendingExtensionItem.extension.name_prefill }}</em></p>
        <div class="autoselect-field__extension-actions">
          <button class="btn normal-input" @click="confirmExtension">Confirm</button>
          <button class="btn normal-input" @click="cancelExtension">Cancel</button>
        </div>
      </template>

      <!-- CoL alignment -->
      <template v-else-if="pendingExtensionItem.extension?.col_key">
        <p><strong>Catalog of Life match:</strong> {{ pendingExtensionItem.extension.col_name }}</p>
        <p v-if="pendingExtensionItem.extension.col_status">
          Status: {{ pendingExtensionItem.extension.col_status }}
        </p>
        <table
          v-if="pendingExtensionItem.extension.alignment?.length"
          class="autoselect-field__alignment-table"
        >
          <thead>
            <tr>
              <th>Rank</th>
              <th>CoL name</th>
              <th>TaxonWorks match</th>
              <th>Match</th>
            </tr>
          </thead>
          <tbody>
            <tr
              v-for="row in pendingExtensionItem.extension.alignment"
              :key="row.rank"
            >
              <td>{{ row.rank }}</td>
              <td>{{ row.col_name }}</td>
              <td>{{ row.taxonworks_name ?? '—' }}</td>
              <td>{{ row.match }}</td>
            </tr>
          </tbody>
        </table>
        <div class="autoselect-field__extension-actions">
          <button class="btn normal-input" @click="confirmExtension">Confirm</button>
          <button class="btn normal-input" @click="cancelExtension">Cancel</button>
        </div>
      </template>
    </div>
  </div>
</template>

<script setup>
import { ref, computed, onMounted, nextTick } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { useAutoselect } from '@/components/ui/AutoselectField/useAutoselect'

// ── Props & emits ─────────────────────────────────────────────────────────────
const props = defineProps({
  url: {
    type: String,
    required: true
  },
  modelValue: {
    type: Object,
    default: null
  },
  param: {
    type: String,
    required: true
  },
  placeholder: {
    type: String,
    default: 'Search...'
  },
  disabled: {
    type: Boolean,
    default: false
  }
})

const emit = defineEmits(['update:modelValue', 'select'])

// ── Composable ────────────────────────────────────────────────────────────────
const {
  config,
  fetchConfig,
  getFirstLevelKey,
  getNextLevelKey,
  isExternalLevel,
  getFuseMs,
  getOperators
} = useAutoselect(props.url)

// ── State ─────────────────────────────────────────────────────────────────────
const inputEl = ref(null)
const dropdownEl = ref(null)

const ready = ref(false)
const inputText = ref('')
const currentLevel = ref(null)
const dropdownItems = ref([])
const highlightedIndex = ref(-1)
const isSearching = ref(false)
const pendingExtensionItem = ref(null)

// Fuse state
const fuseActive = ref(false)
const fuseRunning = ref(false)
const currentFuseMs = ref(600)
const nextLevel = ref(null)
let fuseTimer = null

// Overlay states
const showHelp = ref(false)
const isFocused = ref(false)

const showDropdown = computed(() => isFocused.value && dropdownItems.value.length > 0)

const visibleOperators = computed(() =>
  getOperators().filter((op) => !op.client_only)
)

// Debounce handle
let searchDebounce = null
let abortController = null

// ── Lifecycle ──────────────────────────────────────────────────────────────────
onMounted(async () => {
  await fetchConfig()
  currentLevel.value = getFirstLevelKey()
  ready.value = true
})

// ── Operator detection ────────────────────────────────────────────────────────
const CLIENT_ONLY_PATTERNS = [
  { pattern: /^\!\?/, key: 'help' },
  { pattern: /^\!#/, key: 'level_hash' },
  { pattern: /^\!(\d+)/, key: 'level_number' }
]

function detectClientOperator(text) {
  for (const { pattern, key } of CLIENT_ONLY_PATTERNS) {
    if (pattern.test(text)) return key
  }
  return null
}

// ── Input handler ─────────────────────────────────────────────────────────────
function onInput() {
  const text = inputText.value

  if (!text.trim()) {
    closeDropdown()
    cancelFuse()
    return
  }

  const clientOp = detectClientOperator(text)
  if (clientOp === 'help') {
    showHelp.value = true
    return
  }
  if (clientOp === 'level_hash' || clientOp === 'level_number') {
    // client-only level navigation — future enhancement placeholder
    return
  }

  clearTimeout(searchDebounce)
  searchDebounce = setTimeout(() => {
    performSearch(text, currentLevel.value)
  }, 200)
}

// ── Search ────────────────────────────────────────────────────────────────────
async function performSearch(term, level) {
  if (!term || !level) return

  abortController?.abort()
  abortController = new AbortController()
  isSearching.value = true
  cancelFuse()

  try {
    const { body } = await AjaxCall('get', props.url, {
      params: { term, level },
      signal: abortController.signal
    })

    if (!body) return

    const results = body.response ?? []
    dropdownItems.value = results
    highlightedIndex.value = -1

    if (results.length === 0 && body.next_level) {
      lightFuse(body.next_level)
    }
  } catch (e) {
    if (e?.code !== 'ERR_CANCELED') {
      console.warn('[AutoselectField] Search error:', e)
    }
  } finally {
    isSearching.value = false
  }
}

// ── Fuse mechanic ─────────────────────────────────────────────────────────────
function lightFuse(targetLevel) {
  if (!targetLevel) return
  nextLevel.value = targetLevel
  currentFuseMs.value = getFuseMs(targetLevel)
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
}

function triggerEscalation() {
  const target = nextLevel.value
  cancelFuse()
  if (target) escalateToLevel(target)
}

function escalateToLevel(level) {
  currentLevel.value = level
  performSearch(inputText.value, level)
}

// ── Selection ─────────────────────────────────────────────────────────────────
function selectItem(item) {
  closeDropdown()
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
  if (pendingExtensionItem.value) {
    completeSelection(pendingExtensionItem.value)
  }
}

function cancelExtension() {
  pendingExtensionItem.value = null
}

// ── Keyboard navigation ───────────────────────────────────────────────────────
function moveSelection(delta) {
  const items = dropdownItems.value
  if (!items.length) return
  highlightedIndex.value = Math.max(
    0,
    Math.min(items.length - 1, highlightedIndex.value + delta)
  )
}

function confirmHighlighted() {
  if (highlightedIndex.value >= 0 && dropdownItems.value[highlightedIndex.value]) {
    selectItem(dropdownItems.value[highlightedIndex.value])
  }
}

// ── Focus management ──────────────────────────────────────────────────────────
function onFocus() {
  isFocused.value = true
}

function onBlur() {
  // Small delay to allow mousedown on dropdown items to fire first
  setTimeout(() => {
    isFocused.value = false
  }, 150)
}

function closeDropdown() {
  dropdownItems.value = []
  highlightedIndex.value = -1
  isFocused.value = false
}
</script>

<style scoped>
.autoselect-field {
  position: relative;
  width: 100%;
}

.autoselect-field__input-row {
  display: flex;
  align-items: center;
  gap: 4px;
}

.autoselect-field__input {
  flex: 1;
  min-width: 0;
}

.autoselect-field__spinner {
  font-size: 16px;
  line-height: 1;
  user-select: none;
}

/* Fuse bar */
.autoselect-field__fuse-bar {
  height: 3px;
  background: var(--border-color, #ccc);
  cursor: pointer;
  overflow: hidden;
  border-radius: 2px;
  margin-top: 2px;
}

.autoselect-field__fuse-fill {
  height: 100%;
  width: 0%;
  background: var(--color-primary, #4a90e2);
  transition-property: width;
  transition-timing-function: linear;
}

.autoselect-field__fuse-fill--running {
  width: 100%;
}

/* Dropdown */
.autoselect-field__dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  right: 0;
  z-index: 9999;
  margin: 0;
  padding: 0;
  list-style: none;
  max-height: 300px;
  overflow-y: auto;
  background-color: var(--panel-bg-color, #fff);
  border: 1px solid var(--border-color, #ccc);
  border-top: none;
  border-radius: 0 0 3px 3px;
}

.autoselect-field__dropdown-item {
  padding: 4px 8px;
  cursor: pointer;
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  gap: 8px;
  font-size: 12px;
}

.autoselect-field__dropdown-item--highlighted {
  background-color: var(--color-primary, #4a90e2);
  color: white;
}

.autoselect-field__item-label {
  flex: 1;
}

.autoselect-field__item-info {
  font-size: 10px;
  opacity: 0.7;
  white-space: nowrap;
}

/* Help overlay */
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
}

.autoselect-field__help-overlay h4 {
  margin: 0 0 6px;
  font-size: 13px;
}

.autoselect-field__help-overlay ul {
  margin: 0 0 8px;
  padding-left: 16px;
}

.autoselect-field__help-close {
  font-size: 11px;
}

/* Extension panel */
.autoselect-field__extension-panel {
  border: 1px solid var(--border-color, #ccc);
  border-top: none;
  padding: var(--standard-padding, 8px);
  font-size: 12px;
  background: var(--panel-bg-color, #fff);
}

.autoselect-field__extension-actions {
  display: flex;
  gap: 6px;
  margin-top: 8px;
}

/* CoL alignment table */
.autoselect-field__alignment-table {
  width: 100%;
  border-collapse: collapse;
  margin: 6px 0;
  font-size: 11px;
}

.autoselect-field__alignment-table th,
.autoselect-field__alignment-table td {
  border: 1px solid var(--border-color, #ccc);
  padding: 3px 6px;
  text-align: left;
}

.autoselect-field__alignment-table th {
  background: var(--input-bg-color, #f5f5f5);
  font-weight: 600;
}
</style>
