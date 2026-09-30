<template>
  <div
    :id="effectiveId"
    class="autoselect"
    data-help='An autoselect. Type "!?" to get help on using it.'
  >
    <!-- Fuse bar — segmented, above input; hidden levels are not rendered -->
    <div class="autoselect__fuse-track">
      <VTooltip
        v-for="(seg, idx) in visibleFuseSegments"
        :key="seg.key"
        tag="div"
        placement="bottom"
        :arrow="false"
        tooltip-class="tw-tooltip--panel"
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
      >
        <template #content>
          <div class="autoselect__fuse-tooltip">
            <span class="autoselect__fuse-tooltip-trigger">!{{ idx + 1 }}</span>
            <span class="autoselect__fuse-tooltip-label">{{
              seg.displayLabel
            }}</span>
            <span class="autoselect__fuse-tooltip-desc">{{
              seg.description
            }}</span>
          </div>
        </template>

        <!-- Orange ignition sweep -->
        <div
          v-if="ignitedSegmentKey === seg.key"
          class="autoselect__fuse-ignition"
          :style="{ transitionDuration: currentFuseMs + 'ms' }"
          :class="{ 'autoselect__fuse-ignition--running': fuseRunning }"
        />
      </VTooltip>
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
            <span
              class="autoselect__item-label"
              v-html="item.label_html || item.label"
            />
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
          :class="{ 'autoselect__dropdown-none--flash': pinboardNoneFlash }"
        >
          None
        </li>
      </ul>
    </teleport>

    <!-- Help overlay (!?) — teleported to escape any scrollable/clipping
         ancestor (e.g. a table wrapper with overflow-x: auto), same reason
         the dropdown and fuse tooltip are teleported. Position is computed
         in JS (updateHelpOverlayPosition) from the input's own bounding
         rect, same technique as those. -->
    <teleport to="body">
      <div
        v-if="showHelp"
        class="autoselect__help-overlay"
        :style="helpOverlayStyle"
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
            <code
              v-else
              class="autoselect__help-trigger-muted"
            >{{ op.trigger }}</code>
            <span class="autoselect__help-desc"> — {{ op.description }}</span>
          </li>
        </ul>
      </div>
    </teleport>

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
        :current-prefs="prefsForModal"
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
import { randomUUID } from '@/helpers'
import { useAutoselect } from '@/components/ui/AutoselectField/useAutoselect'
import { usePreferences } from '@/components/ui/AutoselectField/usePreferences'
import VTooltip from '@/components/ui/VTooltip/VTooltip.vue'
import ColConfirmModal from '@/components/ui/AutoselectField/ColConfirmModal.vue'
import PreferencesModal from '@/components/ui/AutoselectField/PreferencesModal.vue'
import CatalogueOfLifeSpinner from '@/components/ui/AutoselectField/CatalogueOfLifeSpinner.vue'
import TaxonWorksSpinner from '@/components/ui/AutoselectField/TaxonWorksSpinner.vue'

const LEVEL_SPINNERS = {
  catalogue_of_life: CatalogueOfLifeSpinner,
  // Always a CoL round-trip while searching, regardless of whether the result
  // turns out to be an existing TW match or a creation offer once it arrives.
  col_valid_name: CatalogueOfLifeSpinner
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
  // Used as the root div id and, unless preferencesKey is set, as the
  // preferences storage key. When omitted a UUID is generated automatically.
  id: { type: String, default: null },
  // Key the !p preferences are stored under. Set this when several instances
  // should share preferences but must keep distinct DOM ids (e.g. two
  // determination pickers on one page). Defaults to the effective id.
  preferencesKey: { type: String, default: null },
  // Vue component to render when !n is triggered (null = disabled).
  newRecordComponent: { type: Object, default: null },
  // Vue component rendered inside PreferencesModal for model-specific options (null = none).
  preferencesOptionsComponent: { type: Object, default: null },
  // When true, clear the field and reset to level 0 after selection instead of filling
  // the input with the selected label.  Use for "append to list" contexts where the
  // field should be ready for the next search immediately after each pick.
  resetOnSelect: { type: Boolean, default: false },
  // Focus the input once it's actually usable. A plain HTML `autofocus` attribute
  // (or focusing from a parent right after mount) doesn't work here: the input is
  // `:disabled` until the initial config fetch resolves, and browsers won't focus
  // a disabled element. This waits for that internally instead of callers having to
  // guess when the field becomes ready.
  autofocus: { type: Boolean, default: false },
  // Controlled level visibility. When bound (an array of level keys), it — not this
  // instance's localStorage preference — decides which levels appear in the fuse
  // bar, and the `!p` modal's level checkboxes emit `update:visibleLevels` rather
  // than persisting a `hide` flag. `show_info`, `auto_jump` and per-level options
  // still persist to localStorage either way. Leave unbound (null) for the default:
  // each instance remembers its own visible levels, seeded from each level's
  // `is_default`. Treat the array as immutable — replace it, don't mutate in place,
  // or the change won't be observed.
  visibleLevels: { type: Array, default: null }
})

const emit = defineEmits(['update:modelValue', 'select', 'update:visibleLevels'])

// ── Effective id (prop or UUID) ────────────────────────────────────────────────
const effectiveId = props.id ?? `autoselect_${randomUUID()}`

// ── Composables ────────────────────────────────────────────────────────────────
const { config, fetchConfig, getFirstLevelKey, getOperators } = useAutoselect(
  props.url
)

const prefs = usePreferences(props.url, props.preferencesKey ?? effectiveId)

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
const ignitedSegmentKey = ref(null) // keyed by level key, not index
let fuseTimer = null

// pinboard "None" flash state
const pinboardNoneFlash = ref(false)
let pinboardNoneTimer = null

const helpOverlayStyle = ref({})

// Page-absolute coordinates so the teleported overlay isn't clipped by a
// scrollable ancestor (e.g. a table wrapper with overflow-x: auto).
function updateHelpOverlayPosition() {
  const rect = inputEl.value?.getBoundingClientRect()
  if (!rect) return
  helpOverlayStyle.value = {
    top: `${rect.bottom + window.scrollY}px`,
    left: `${rect.left + window.scrollX}px`,
    width: `${rect.width}px`
  }
}

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
    // A level may search with another level's options (see
    // Autoselect::Level#options_level) — label it with those too.
    const optionsKey = l.options_level ? String(l.options_level) : key
    const options = currentPrefs.value.levels?.[optionsKey]?.options || {}
    const displayLabel = options.dataset_title
      ? `${l.label} (${options.dataset_title})`
      : l.label
    return {
      key,
      label: l.label,
      displayLabel,
      description: l.description,
      external: l.external ?? false,
      fuse_ms: l.fuse_ms ?? 600,
      is_default: l.is_default ?? true,
      optionsKey
    }
  })
)

// Segments visible after applying preferences (hide flag), or — when the parent
// binds `visibleLevels` — after applying that controlled list instead.
const visibleFuseSegments = computed(() =>
  props.visibleLevels === null
    ? allFuseSegments.value.filter((s) => prefs.isLevelVisible(s.key, s.is_default))
    : allFuseSegments.value.filter((s) => props.visibleLevels.includes(s.key))
)

// Prefs handed to the !p modal. In controlled mode the stored `hide` flags aren't
// consulted for visibility, so project the controlled list onto them — otherwise a
// level the parent is showing would appear unchecked in the modal (and vice versa).
const prefsForModal = computed(() => {
  const base = currentPrefs.value
  if (props.visibleLevels === null) return base

  const levels = { ...(base.levels || {}) }
  for (const seg of allFuseSegments.value) {
    levels[seg.key] = {
      ...(levels[seg.key] || {}),
      hide: !props.visibleLevels.includes(seg.key)
    }
  }
  return { ...base, levels }
})

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
// Both the dropdown and the (teleported, page-absolute) help overlay are positioned
// from the input's bounding rect, so both go stale on a window resize. The help
// overlay otherwise only repositions when `!?` is (re)typed.
function repositionTeleportedOverlays() {
  updateDropdownPosition()
  if (showHelp.value) updateHelpOverlayPosition()
}

onMounted(async () => {
  await fetchConfig()
  currentLevel.value = getFirstVisibleLevelKey()
  ready.value = true
  window.addEventListener('resize', repositionTeleportedOverlays)

  if (props.autofocus) {
    // ready just flipped true, but the :disabled binding hasn't repainted yet.
    await nextTick()
    inputEl.value?.focus()
  }
})

onBeforeUnmount(() => {
  window.removeEventListener('resize', repositionTeleportedOverlays)
  cancelPinboardNoneFlash()
})

// Parent changed the controlled visible-levels list (e.g. a task-wide toggle that
// drives every field at once). Segments re-derive reactively; only the active
// level needs rescuing if it just disappeared. The replacement is the leftmost
// visible segment (fuse-bar order, only levels the config knows), not the
// parent's levels[0]. Anything still in flight for the old level is dropped so
// it can't repopulate the dropdown, then the term re-runs on the new level —
// same as onPrefsSave.
watch(
  () => props.visibleLevels,
  (levels) => {
    if (levels === null || !ready.value) return
    if (visibleFuseSegments.value.some((s) => s.key === currentLevel.value)) {
      return
    }

    currentLevel.value = getFirstVisibleLevelKey()
    if (getRequest) clearTimeout(getRequest)
    controller.value?.abort()
    isSearching.value = false
    cancelFuse()
    clearResults()

    const term = inputText.value.trim()
    if (term) triggerSearch(term)
  }
)

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
    inputText.value = (helpMatch[1] + ' ' + helpMatch[2])
      .replace(/\s+/g, ' ')
      .trim()
    updateHelpOverlayPosition()
    showHelp.value = true
    return
  }

  // !p — preferences modal
  const prefMatch = text.match(/^(.*?)\s*!p\s*(.*)$/i)
  if (prefMatch !== null) {
    preInputText = (prefMatch[1] + ' ' + prefMatch[2])
      .replace(/\s+/g, ' ')
      .trim()
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
    const cleanTerm = (infoMatch[1] + ' ' + infoMatch[2])
      .replace(/\s+/g, ' ')
      .trim()
    inputText.value = cleanTerm
    prefs.toggleShowInfo()
    currentPrefs.value = prefs.getPrefs()
    return
  }

  // !n — new record modal
  const newRecordMatch = text.match(/^(.*?)\s*!n\s*(.*)$/i)
  if (newRecordMatch !== null && props.newRecordComponent !== null) {
    const cleanName = (newRecordMatch[1] + ' ' + newRecordMatch[2])
      .replace(/\s+/g, ' ')
      .trim()
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
      const cleanTerm = (externalMatch[1] + ' ' + externalMatch[2])
        .replace(/\s+/g, ' ')
        .trim()
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

  // Pinboard operators: skip debounce
  if (/^!!/.test(text) || /^!b/.test(text)) {
    cancelFuse()
    if (getRequest) clearTimeout(getRequest)
    triggerSearch(text)
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

  cancelPinboardNoneFlash()
  controller.value?.abort()
  controller.value = new AbortController()
  isSearching.value = true
  dropdownItems.value = []

  // Merge current level's preference options (or those of the level it takes
  // its options from) and global prefs into the request params
  const currentSegment = allFuseSegments.value.find(
    (s) => s.key === currentLevel.value
  )
  const levelOptions = prefs.getLevelOptions(
    currentSegment?.optionsKey ?? currentLevel.value
  )

  AjaxCall('get', props.url, {
    params: {
      term,
      level: currentLevel.value,
      ...levelOptions,
      show_info: prefs.getShowInfo()
    },
    signal: controller.value.signal
  })
    .then(({ body }) => {
      if (!body) return
      const results = body.response ?? []
      const responseOperator = body.request?.operator

      // !! — auto-select the topmost pinboard item immediately
      if (responseOperator === 'pinboard_top' && results.length === 1) {
        completeSelection(results[0])
        return
      }

      dropdownItems.value = results
      showList.value = true
      searchEnd.value = true
      current.value = -1
      nextTick(updateDropdownPosition)

      // !b / !! with no results: brief "None" flash then clear
      if (
        (responseOperator === 'pinboard' ||
          responseOperator === 'pinboard_top') &&
        results.length === 0
      ) {
        pinboardNoneFlash.value = true
        pinboardNoneTimer = setTimeout(() => {
          pinboardNoneFlash.value = false
          showList.value = false
          inputText.value = ''
          searchEnd.value = false
        }, 1200)
        return
      }

      if (results.length === 0 && body.next_level && prefs.getAutoJump()) {
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

    dropdown.style.removeProperty('width')
    dropdown.style.minWidth = '0'
    dropdown.style.maxHeight = maxHeight + 'px'
    dropdown.style.maxWidth = maxWidth + 'px'

    const contentWidth = dropdown.scrollWidth
    dropdown.style.minWidth = rect.width + 'px'

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

watch([dropdownItems, showList, showInfo], () => {
  if (showList.value) updateDropdownPosition()
})

// ── Fuse mechanic ──────────────────────────────────────────────────────────────
function lightFuse(targetLevel) {
  if (!targetLevel) return

  const seg = visibleFuseSegments.value.find(
    (s) => s.key === String(currentLevel.value)
  )

  nextLevel.value = targetLevel
  currentFuseMs.value = seg?.fuse_ms ?? 600
  ignitedSegmentKey.value = String(currentLevel.value)
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
  pendingExtensionItem.value = null

  // Captured before inputText is overwritten/cleared below — the raw text the
  // user typed to arrive at this item, for callers that want to flag when the
  // matched result isn't what was searched for (e.g. a synonym resolution).
  const searchText = inputText.value

  if (props.resetOnSelect) {
    emit('select', item, searchText)
    emit('update:modelValue', null)
    inputText.value = ''
    currentLevel.value = getFirstVisibleLevelKey()
    clearResults()
    nextTick(() => inputEl.value?.focus())
  } else {
    inputText.value = item.label ?? ''
    emit('update:modelValue', item)
    emit('select', item, searchText)
  }
}

function cancelExtension() {
  pendingExtensionItem.value = null
  nextTick(() => inputEl.value?.focus())
}

function onColConfirm({ id: createdId, global_id: createdGlobalId }) {
  const yieldsKey =
    pendingExtensionItem.value.extension?.hook?.yields ?? 'taxon_name_id'
  completeSelection({
    id: createdId,
    global_id: createdGlobalId,
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
  // Resolve the levels the modal's checkboxes leave visible, from the same
  // hide/is_default rule the modal itself uses. Read from the modal's emitted
  // prefs (before the controlled-mode stripping below).
  const nextVisibleKeys = allFuseSegments.value
    .filter((s) => {
      const hide = updatedPrefs.levels?.[s.key]?.hide
      return hide === undefined ? s.is_default : !hide
    })
    .map((s) => s.key)

  // In controlled mode the parent owns level visibility, so the per-level `hide`
  // flags must not be persisted (see lib/autoselect/ARCHITECTURE.md). Persisting
  // them would freeze a copy of the controlled list onto this instance and stop
  // it falling back to each level's is_default once the parent unbinds. Keep only
  // what persists regardless: per-level `options`, plus show_info / auto_jump.
  const prefsToPersist =
    props.visibleLevels === null
      ? updatedPrefs
      : {
          ...updatedPrefs,
          levels: Object.fromEntries(
            Object.entries(updatedPrefs.levels ?? {})
              .map(([key, level]) => {
                const persisted = { ...level }
                delete persisted.hide
                return [key, persisted]
              })
              .filter(([, persisted]) => Object.keys(persisted).length > 0)
          )
        }

  prefs.savePrefs(prefsToPersist)
  currentPrefs.value = prefsToPersist
  showPreferences.value = false

  // In controlled mode the parent owns visibility — hand it the new list and let
  // it flow back through the prop.
  if (props.visibleLevels !== null) {
    emit('update:visibleLevels', nextVisibleKeys)
  }

  // If the current level was hidden, jump to the first still-visible level.
  // (In uncontrolled mode visibleFuseSegments already reflects the just-saved
  // prefs; in controlled mode the prop update is async, so check nextVisibleKeys.)
  const stillVisible = props.visibleLevels === null
    ? visibleFuseSegments.value.some((s) => s.key === currentLevel.value)
    : nextVisibleKeys.includes(currentLevel.value)
  if (!stillVisible) {
    currentLevel.value = nextVisibleKeys[0] ?? getFirstLevelKey()
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

// Fill the field from the outside, run the search, and leave the caret at the end so the
// text can be trimmed straight away. Used where a caller already knows a good starting term.
// @param text [String]
function prefill(text) {
  inputText.value = text ?? ''
  onInput()

  nextTick(() => {
    const el = inputEl.value
    if (!el) return
    el.focus()
    const len = el.value.length
    el.setSelectionRange(len, len)
  })
}

// @return {String} current input text — the complement of prefill(), for a
// caller that swaps this field out and wants to carry the term to its replacement.
function getSearchText() {
  return inputText.value
}

defineExpose({ prefill, getSearchText })

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
function cancelPinboardNoneFlash() {
  if (pinboardNoneTimer) {
    clearTimeout(pinboardNoneTimer)
    pinboardNoneTimer = null
  }
  pinboardNoneFlash.value = false
}

function clearResults() {
  cancelPinboardNoneFlash()
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
  transition:
    flex 0.25s ease,
    height 0.25s ease;
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
  display: flex;
  flex-direction: column;
  gap: 1px;
  font-size: 11px;
  line-height: 1.5;
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
  color: var(--text-muted-color, #666);
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
  width: auto;
  min-width: 100%;
  max-width: calc(100vw - 32px);
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

.autoselect__item-label {
  flex: 1 1 auto;
  min-width: 0;
}

.autoselect__item-info {
  flex: 0 0 auto;
  font-size: 10px;
  opacity: 0.7;
  white-space: nowrap;
}

.autoselect__dropdown-none {
  padding: 6px 12px;
  border-top: 1px solid var(--border-color);
  font-size: 12px;
  color: var(--text-muted-color, #888);
}

@keyframes autoselect-none-fade {
  0%,
  40% {
    opacity: 1;
  }
  100% {
    opacity: 0;
  }
}

.autoselect__dropdown-none--flash {
  animation: autoselect-none-fade 1.2s ease-out forwards;
}

/* ── Help overlay ── */
.autoselect__help-overlay {
  /* top/left/width are page-absolute pixel coordinates set via :style (see
     updateHelpOverlayPosition) — teleported to body, so this positions
     against the page's containing block, not a parent that might clip it. */
  position: absolute;
  z-index: 999998;
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
  color: var(--text-muted-color, #888);
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

/* Non-linkable operators (e.g. !n with no newRecordComponent) render as plain
   <code> instead of a <button> — same size as the clickable ones, but muted,
   so it's visually clear before you try arrow-navigating to it that this one
   isn't part of that focus order. */
.autoselect__help-trigger-muted {
  color: var(--text-muted-color, #666);
}

.autoselect__help-desc {
  color: var(--text-color, #333);
}
</style>
