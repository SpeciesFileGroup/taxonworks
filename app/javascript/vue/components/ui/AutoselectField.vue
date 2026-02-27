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
          { 'autoselect-field__fuse-segment--ignited': ignitedSegmentIdx === idx },
          { 'autoselect-field__fuse-segment--active': fuseSegments[idx]?.key === currentLevel }
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
          <span class="autoselect-field__fuse-tooltip-trigger">!{{ idx + 1 }}</span>
          <span class="autoselect-field__fuse-tooltip-label">{{ seg.label }}</span>
          <span class="autoselect-field__fuse-tooltip-desc">{{ seg.description }}</span>
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
        :title="isExternalLevel(currentLevel) ? 'Searching Catalog of Life...' : 'Searching...'"
      >
        <template v-if="isExternalLevel(currentLevel)">&#127760;</template>
        <template v-else>
          <span class="tw-spinner autoselect-field__tw-spinner">
            <svg
              version="1.1"
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 194.6 200"
              xml:space="preserve"
            >
              <path id="LeftTop" d="M14.2,63.1C24.3,63.1,28,76.3,28,76.3s5,15.5,15.3,15.5c7.7,0,9.4-6.3,9.8-9.1c0-0.1,0-0.2,0-0.4s0-0.5,0.1-0.8c0-0.1,0-0.1,0-0.2c0.3-2-0.8-4-2.7-4.8l0,0c-3.1-1.1-5.9-3-8-5.6c-6.4-7.4-3-17,4.5-23.6c-3.5-4-8-8.7-12-10.8c-8.7-4.6-15.7,2.6-16.2,3.2L18.7,40c-0.6,0.8-1.2,1.6-1.8,2.5l-0.1,0.1c-0.6,0.9-1.2,1.8-1.8,2.7L15,45.4c-0.5,0.8-1,1.6-1.5,2.4l-0.3,0.5c-1,1.8-2,3.6-3,5.5L10,54.3c-0.4,0.9-0.9,1.8-1.3,2.7l-0.1,0.1C8.2,58,7.8,59,7.4,59.9l-0.2,0.5c-0.3,0.8-0.6,1.5-0.9,2.3l-0.2,0.6c-0.4,1-0.7,1.9-1,2.9L5,66.7c-0.1,0.3-0.2,0.5-0.2,0.8C7.1,64.7,10.5,63.1,14.2,63.1z" />
              <path id="Head" d="M36.2,33c5.3,1.8,11.4,6.8,15.7,11c0.5-0.3,1.1-0.6,1.6-0.9c2.3-1.2,4.7-2.1,7.2-2.7c-2.4-4.9-5.6-12.8-4.9-18.3c1.4-11.2,13.6-12,13.6-12S58.3,12.5,59,22.9c0.3,5,4.7,12.5,7.5,16.8c7-0.1,13,2.7,15.8,8c0.3,0.5,0.5,1.1,0.7,1.6l0,0c0.5,1,1.3,1.9,2.3,2.4c3.6,1.2,7.6,2.5,11.7,4.2c5.8,2.3,11.5,5,17,8.1c0.5,0.2,1,0,1.2-0.5c0.1-0.3,0.1-0.7-0.2-0.9c-27.2-26.1-8-36.3-8-36.3c-9.8,14.2,6.6,24.5,25.5,35.1c16.6,9.3,28.4,19.5,41.3,12.7c6.4-3.4,1.9-11-1-15.2c-2.2-2.9-4-6-5.6-9.2c-1-2.1-1.3-4.4-0.8-6.6c0.7-3.1-0.4-6.8-2.8-10.5c-1.8-2.8-5.1-5.7-7.6-7.6c-1.6-1.3-3.1-2.7-4.3-4.4c-9-12.6-32.2-17.9-32.2-17.9l0,0C97.5-2.6,74.3,0.1,54,10.2l0,0c-6.9,3.5-13.5,7.7-19.4,12.7l-0.8,0.6c-1.4,1.2-2.8,2.5-4.2,3.8l0,0c-0.8,0.8-1.6,1.5-2.3,2.3l0,0c-1.5,1.6-3,3.2-4.4,4.9l-0.2,0.2l-0.4,0.5C25.2,32.8,29.6,30.9,36.2,33z M145.8,33.9c3.9-1.7,8.5,0.1,10.2,4c0.6,1.3,0.8,2.7,0.6,4c-2.5,1.2-5.5,0.9-7.7-0.9C146.5,39.5,145.3,36.7,145.8,33.9L145.8,33.9z" />
              <path id="LeftMid" d="M53.2,106.9c-0.2-2-0.4-4-0.4-6.3c-2.3,1-4.7,1.5-7.2,1.5c-19,0-19.5-18.8-26.2-29.2c-7-10.8-16.8,0.9-17.8,7.2c0,0.3-0.1,0.5-0.1,0.7c-0.1,0.6-0.2,1.3-0.3,1.9C1,83.1,1,83.4,1,83.6c-0.1,0.8-0.2,1.6-0.3,2.3c0,0.3-0.1,0.5-0.1,0.8c-0.1,1-0.2,2.1-0.3,3.1c0,0.1,0,0.2,0,0.3c-0.1,0.9-0.2,1.9-0.2,2.8c0,0.3,0,0.6,0,0.9C0,94.9,0,95.8,0,96.7c0,0.1,0,0.2,0,0.3s0,0.1,0,0.1s0,0.1,0,0.1c0,0.4,0,0.8,0,1.2s0,0.8,0,1.2c0,0.6,0,1.2,0.1,1.7c0,0.2,0,0.5,0,0.7c1.5,30.7,17.5,58.9,43,76c-8-7.8-12.7-17.8-12.7-28.6c0-13.4,7.3-26,19.1-34.4C52,113.2,53.5,110.1,53.2,106.9z" />
              <path id="LeftBottom" d="M128.3,170c-5.8,2.4-12,3.9-18.3,4.4c-1.1,0.1-2.2,0.1-3.3,0.1c-12.3,0-28.4-4.8-40.7-25.3l-1.6-2.7c-1.9,2.7-2.9,6-2.9,9.3c0,13.9,16.6,26.5,36.7,26.5c5.4,0.1,10.7-0.6,15.9-2c-4.6,2.9-13.8,5.6-21.9,5.6C69.2,186,50,170.8,50,152.7c0.1-6.3,2.1-12.5,5.8-17.6c1.5-2.1,1.9-4.8,1.1-7.2l0,0c-10.5,6.1-17,15.4-17,26.6c0,17.2,15.3,31.9,37,37.9c1.2,0.3,2.5,0.5,3.7,0.7c15.6,2.6,29.5-0.1,38.9-9.1C123.5,180.1,126.5,175.3,128.3,170z" />
              <path id="Tail" d="M171,33.8c28,39.3,18.8,93.8-20.5,121.8c-2.4,1.7-4.9,3.3-7.5,4.8l-0.2,0.2c0-0.4,0-0.9,0.1-1.3c0.6-3.9,2.1-7.6,4.4-10.8c7.5-10.7,12.4-27-0.3-48.1c-7-11.6-21.7-28-51.7-40.1c-4.1-1.7-8.1-3.1-11.8-4.2L82,55.6l-0.2-0.1c-1.1-0.3-2.1-0.6-3.1-0.9h-0.2l-2.9-0.8h-0.1l-1.3-0.3h-0.1l-2.6-0.6h-0.1l-2.3-0.5h-0.2l-1-0.2l0,0L67,51.7h-0.2l-0.7-0.2h-0.2l-0.8-0.2H65l-0.6-0.1h-0.2L63.7,51l-0.1,0.4v0.1l-0.1,0.3l0,0.2l-0.1,0.3l-0.1,0.2l-0.1,0.3l-0.1,0.2L63,53.5L63,53.7l-0.1,0.4l-0.1,0.2l-0.1,0.5l-0.1,0.3l-0.1,0.6L62.3,56l-0.1,0.5l-0.1,0.3L62,57.2l-0.1,0.4L61.8,58l-0.1,0.4l-0.1,0.5l-0.1,0.4l-0.1,0.5l-0.1,0.4l-0.1,0.6l-0.1,0.5L61,61.9l-0.1,0.4l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5l-0.1,0.5L60,66.9l-0.1,0.5l-0.1,0.7l-0.1,0.5l-0.2,1l-0.1,0.5l-0.1,0.6l-0.1,0.5l-0.1,0.6l-0.1,0.6L59,73.1l-0.1,0.6l-0.1,0.6l-0.1,0.6l-0.1,0.7l-0.1,0.6l-0.1,0.8l-0.1,0.5c-0.2,1.8-0.4,3.6-0.6,5.5V83c0,0.6-0.1,1.1-0.1,1.7l0,0c0,0.6-0.1,1.1-0.1,1.7v0.1c0,0.6-0.1,1.1-0.1,1.7l0,0c-0.2,3-0.2,6.2-0.2,9.5c0.1,4.3,0.4,8.5,0.8,12.7c0,0.3,0.1,0.7,0.1,1.1c0.7,5.8,1.9,11.4,3.6,17c1.5,4.5,3.2,8.9,5.2,13.2c0.9,1.7,1.8,3.4,2.8,5.1c9.2,15.3,21.5,23,36.6,23c1,0,2.1,0,3.2-0.1c7-0.6,13.9-2.5,20.2-5.6c4.9-24.5-8.4-59.3-36.1-88.3C90,71.8,86,68,81.7,64.4c9.2,6.9,13.9,10.7,19.2,16.3c37.8,39.6,49.7,89.7,26.5,111.9c-3.4,3.3-7.5,5.8-11.9,7.5c5.8-1.6,11.1-4.5,15.4-8.6c1.4-1.3,2.6-2.7,3.8-4.2c49.6-20.7,73-77.7,52.4-127.3C183.1,50.4,177.7,41.6,171,33.8z" />
            </svg>
          </span>
        </template>
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
            :key="item.id ?? ('item-' + idx)"
            class="autoselect-field__dropdown-item"
            :class="{ 'autoselect-field__dropdown-item--active': idx === current }"
            @mouseover="current = idx"
            @click.prevent="itemClicked(idx)"
          >
            <span v-html="item.label_html || item.label" />
            <span v-if="item.info" class="autoselect-field__item-info">{{ item.info }}</span>
          </li>
        </template>
        <!-- None shown simultaneously with fuse igniting -->
        <li
          v-else
          class="autoselect-field__dropdown-none"
        >
          --None--
          <span v-if="fuseActive" class="autoselect-field__none-hint">
            &nbsp;searching {{ nextLevelLabel }}…
          </span>
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
        <li v-for="op in visibleOperators" :key="op.trigger">
          <code>{{ op.trigger }}</code> — {{ op.description }}
        </li>
      </ul>
      <button class="btn" @click="showHelp = false">Close</button>
    </div>

    <!-- Extension panel: new-OTU form (inline) -->
    <div
      v-if="pendingExtensionItem?.extension?.mode === 'new_otu_form'"
      class="autoselect-field__extension-panel"
    >
      <p><strong>Create new OTU</strong></p>
      <p>Name: <em>{{ pendingExtensionItem.extension.name_prefill }}</em></p>
      <div class="autoselect-field__extension-actions">
        <button class="btn normal-input" @click="confirmExtension">Confirm</button>
        <button class="btn normal-input" @click="cancelExtension">Cancel</button>
      </div>
    </div>

    <!-- CoL confirmation modal (teleported via Modal.vue) -->
    <ColConfirmModal
      v-if="pendingExtensionItem?.extension?.col_key"
      :item="pendingExtensionItem"
      @confirm="onColConfirm"
      @cancel="cancelExtension"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onBeforeUnmount, nextTick } from 'vue'
import AjaxCall from '@/helpers/ajaxCall'
import { useAutoselect } from '@/components/ui/AutoselectField/useAutoselect'
import ColConfirmModal from '@/components/ui/AutoselectField/ColConfirmModal.vue'

// ── Props & emits ──────────────────────────────────────────────────────────────
const props = defineProps({
  url:         { type: String,  required: true },
  modelValue:  { type: Object,  default: null },
  param:       { type: String,  required: true },
  placeholder: { type: String,  default: 'Search...' },
  disabled:    { type: Boolean, default: false },
  levelDelay:  { type: Number,  default: 500 }   // debounce ms; exposed for playground tuning
})

const emit = defineEmits(['update:modelValue', 'select'])

// ── Composable ─────────────────────────────────────────────────────────────────
const {
  config,
  fetchConfig,
  getFirstLevelKey,
  isExternalLevel,
  getFuseMs,
  getOperators
} = useAutoselect(props.url)

// ── Refs ───────────────────────────────────────────────────────────────────────
const inputEl   = ref(null)
const dropdownEl = ref(null)

// search state — mirrors Autocomplete.vue naming closely
const ready         = ref(false)
const inputText     = ref('')
const currentLevel  = ref(null)
const dropdownItems = ref([])
const current       = ref(-1)       // highlighted index
const isSearching   = ref(false)
const searchEnd     = ref(false)    // true after first search completes (gates dropdown)
const showList      = ref(false)
const dropdownStyle = ref({})
const controller    = ref(null)     // AbortController
let   getRequest    = 0             // debounce handle (matches Autocomplete.vue name)

// fuse state
const fuseActive         = ref(false)
const fuseRunning        = ref(false)
const currentFuseMs      = ref(600)
const nextLevel          = ref(null)
const ignitedSegmentIdx  = ref(null)
let   fuseTimer          = null

// fuse bar hover
const hoveredSegmentIdx = ref(null)

// overlays
const showHelp           = ref(false)
const pendingExtensionItem = ref(null)
let   preventBlur        = false    // mirrors Autocomplete.vue pattern

// ── Computed ───────────────────────────────────────────────────────────────────
const fuseSegments = computed(() =>
  (config.value?.levels ?? []).map((l) => ({
    key:         String(l.key),
    label:       l.label,
    description: l.description,
    external:    l.external ?? false,
    fuse_ms:     l.fuse_ms  ?? 600
  }))
)

const nextLevelLabel = computed(() => {
  const seg = fuseSegments.value.find((s) => s.key === nextLevel.value)
  return seg?.label ?? nextLevel.value ?? ''
})

const visibleOperators = computed(() =>
  getOperators().filter((op) => !op.client_only)
)

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
  const n    = parseInt(match[2], 10) - 1   // !1 → index 0
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

  // !1, !2 … — jump to level, strip operator, search immediately
  const levelOp = detectLevelOperator(text)
  if (levelOp !== null) {
    currentLevel.value = levelOp.levelKey
    inputText.value = levelOp.cleanTerm
    cancelFuse()
    if (levelOp.cleanTerm.length > 0) {
      triggerSearch(levelOp.cleanTerm)
    } else {
      clearResults()
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
    const input    = inputEl.value
    const dropdown = dropdownEl.value
    if (!input || !dropdown) return

    const rect           = input.getBoundingClientRect()
    const viewportHeight = window.innerHeight
    const viewportWidth  = window.innerWidth
    const spaceBelow     = viewportHeight - rect.bottom
    const spaceAbove     = rect.top
    const showAbove      = spaceBelow < 150 && spaceAbove > spaceBelow
    const maxWidth       = viewportWidth - rect.left - 32
    const maxHeight      = Math.min(showAbove ? spaceAbove - 12 : spaceBelow - 12, 500)

    dropdown.style.maxHeight = maxHeight + 'px'
    dropdown.style.minWidth  = rect.width + 'px'
    dropdown.style.maxWidth  = maxWidth + 'px'

    const items        = dropdown.querySelectorAll('li')
    const contentWidth = Array.from(items).reduce((acc, li) => Math.max(acc, li.scrollWidth), 0)
    const finalWidth   = Math.min(contentWidth + 20, maxWidth)
    const dropdownH    = dropdown.offsetHeight || maxHeight
    const top  = showAbove
      ? rect.top  + window.scrollY - dropdownH - 6
      : rect.bottom + window.scrollY + 2
    const left = rect.left + window.scrollX

    dropdownStyle.value = {
      top:      `${Math.max(top, 0)}px`,
      left:     `${Math.max(left, 0)}px`,
      width:    finalWidth + 'px',
      minWidth: rect.width + 'px',
      maxWidth: maxWidth + 'px'
    }
  })
}

// ── Fuse mechanic ──────────────────────────────────────────────────────────────
function lightFuse(targetLevel) {
  if (!targetLevel) return
  nextLevel.value      = targetLevel
  currentFuseMs.value  = getFuseMs(targetLevel)
  const idx            = fuseSegments.value.findIndex((s) => s.key === String(targetLevel))
  ignitedSegmentIdx.value = idx
  fuseActive.value     = true

  nextTick(() => { fuseRunning.value = true })

  fuseTimer = setTimeout(() => {
    escalateToLevel(targetLevel)
  }, currentFuseMs.value)
}

function cancelFuse() {
  clearTimeout(fuseTimer)
  fuseActive.value        = false
  fuseRunning.value       = false
  nextLevel.value         = null
  ignitedSegmentIdx.value = null
}

function escalateToLevel(level) {
  currentLevel.value = level
  cancelFuse()
  if (inputText.value.trim()) {
    triggerSearch(inputText.value)
  }
}

// Clicking a fuse segment: jump directly to that level
function onFuseSegmentClick(seg, idx) {
  // Only allow jumping forward from current level (no going back)
  const currentIdx = fuseSegments.value.findIndex((s) => s.key === currentLevel.value)
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
    id:              taxonNameId,
    label:           pendingExtensionItem.value.label,
    label_html:      pendingExtensionItem.value.label_html,
    info:            '',
    response_values: { taxon_name_id: taxonNameId },
    extension:       {}
  })
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
    const items   = dropdown.querySelectorAll('li')
    const activeEl = items[current.value]
    if (!activeEl) return
    const dRect = dropdown.getBoundingClientRect()
    const iRect = activeEl.getBoundingClientRect()
    if (iRect.bottom > dRect.bottom) dropdown.scrollTop += iRect.bottom - dRect.bottom
    else if (iRect.top < dRect.top)  dropdown.scrollTop -= dRect.top  - iRect.top
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
  current.value  = -1
}

function onDropdownMousedown() {
  preventBlur = true
}

// ── Helpers ────────────────────────────────────────────────────────────────────
function clearResults() {
  dropdownItems.value = []
  showList.value      = false
  searchEnd.value     = false
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
  transition: flex 0.25s ease, height 0.25s ease;
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
  box-shadow: 0 2px 6px rgba(0,0,0,0.15);
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

.autoselect-field__tw-spinner {
  display: inline-flex;
  width: 16px;
  height: 16px;
}

.autoselect-field__tw-spinner svg {
  width: 16px;
  height: 16px;
}

/* ── Dropdown (teleported to body, matches vue-autocomplete-list styling) ── */
.autoselect-field__dropdown {
  position: absolute;
  display: block;
  max-height: 500px;
  overflow-y: auto;
  overflow-x: hidden;
  z-index: 999998;
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

.autoselect-field__none-hint {
  font-style: italic;
  font-size: 10px;
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
  box-shadow: 0 2px 6px rgba(0,0,0,0.15);
}

.autoselect-field__help-overlay h4 {
  margin: 0 0 6px;
  font-size: 13px;
}

.autoselect-field__help-overlay ul {
  margin: 0 0 8px;
  padding-left: 16px;
}

/* ── Extension panel ── */
.autoselect-field__extension-panel {
  border: 1px solid var(--border-color, #ccc);
  padding: var(--standard-padding, 8px);
  font-size: 12px;
  background: var(--panel-bg-color, #fff);
  margin-top: 2px;
}

.autoselect-field__extension-actions {
  display: flex;
  gap: 6px;
  margin-top: 8px;
}

</style>
