<template>
  <div>
    <div class="flex-separate middle">
      <h1>New source</h1>
      <ul class="context-menu">
        <li>
          <label>
            <input
              type="checkbox"
              v-model="settings.autosave"
            />
            Autosave
          </label>
        </li>
        <li>
          <label>
            <input
              type="checkbox"
              v-model="settings.sortable"
            />
            Reorder fields
          </label>
        </li>
        <li>
          <a :href="RouteNames.SourceHub">Back to source hub</a>
        </li>
        <li>
          <PanelSearch ref="panelSearch" />
        </li>
        <li>
          <VRecent />
        </li>
      </ul>
    </div>
    <NavBar class="relative">
      <div class="flex-separate full_width">
        <div class="middle gap-small">
          <template v-if="store.source.id">
            <span
              class="word_break"
              v-html="store.source.cached"
            />

            <div
              class="horizontal-right-content gap-small"
              v-if="store.source.id"
            >
              <CitationTotal :source-id="store.source.id" />
              <VPin
                class="circle-button"
                type="Source"
                :object-id="store.source.id"
              />
              <AddSource
                :project-source-id="store.source.project_source_id"
                :id="store.source.id"
              />
              <RadialAnnotator :global-id="store.source.global_id" />
              <RadialObject :global-id="store.source.global_id" />
            </div>
          </template>
          <span v-else>New record</span>
        </div>
        <div class="nav__buttons gap-small">
          <VIcon
            v-if="isUnsaved"
            name="attention"
            color="attention"
            title="You have unsaved changes."
          />
          <button
            class="button normal-input button-submit button-size"
            type="button"
            :disabled="!store.isSaveAvailable"
            @click="saveSource"
          >
            Save
          </button>
          <CloneSource />
          |
          <button
            v-if="store.source.type === SOURCE_VERBATIM && store.source.id"
            class="button normal-input button-submit button-size"
            type="button"
            @click="convert"
          >
            To BibTeX
          </button>
          <button
            type="button"
            v-help.section.navBar.crossRef
            class="button normal-input button-default button-size"
            @click="showCrossRefForm"
          >
            CrossRef
          </button>
          <button
            type="button"
            class="button normal-input button-default button-size"
            @click="showBibTexForm"
          >
            BibTeX
          </button>

          <button
            class="button normal-input button-default button-size"
            type="button"
            @click="reset"
          >
            New
          </button>
        </div>
        <Autosave
          :disabled="!settings.autosave"
          style="bottom: 0px; left: 0px"
          class="position-absolute full_width"
        />
      </div>
    </NavBar>
    <div class="horizontal-left-content align-start">
      <BlockLayout class="full_width">
        <template #header>
          <div class="flex-separate middle full_width">
            <h3>Source</h3>
          </div>
        </template>
        <template #body>
          <div class="full_width">
            <SourceType
              v-if="store.source.type !== SOURCE_BIBTEX"
              class="margin-medium-bottom"
            />
            <component :is="componentSection[store.source.type]" />
          </div>
        </template>
      </BlockLayout>
      <RightSection class="margin-medium-left" />
    </div>
    <CrossRef
      v-if="isCrossRefModalVisible"
      @close="() => (isCrossRefModalVisible = false)"
    />
    <BibtexButton
      v-if="isBibtexModalVisible"
      @close="() => (isBibtexModalVisible = false)"
    />
    <VSpinner
      v-if="settings.isConverting"
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
      legend="Converting verbatim to BiBTeX..."
    />
    <VSpinner
      v-if="settings.loading"
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
      legend="Loading source..."
    />
  </div>
</template>

<script setup>
import { computed, ref, onMounted } from 'vue'
import { SOURCE_BIBTEX, SOURCE_HUMAN, SOURCE_VERBATIM } from '@/constants'
import { useSettingStore, useSourceStore } from './store'
import { useHotkey } from '@/composables'
import { RouteNames } from '@/routes/routes'

import Autosave from './components/Autosave.vue'

import Verbatim from './components/verbatim/main'
import Bibtex from './components/bibtex/main'
import Human from './components/person/PersonHuman.vue'
import SourceType from './components/sourceType'

import CrossRef from './components/crossRef'
import BibtexButton from './components/bibtex'
import VSpinner from '@/components/ui/VSpinner'
import RadialAnnotator from '@/components/radials/annotator/annotator'
import RadialObject from '@/components/radials/navigation/radial'
import AddSource from '@/components/ui/Button/ButtonAddToProjectSource'
import CloneSource from './components/cloneSource'
import VIcon from '@/components/ui/VIcon/index.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import CitationTotal from './components/CitationTotal.vue'

import VRecent from './components/recent.vue'
import PanelSearch from './components/PanelSearch.vue'
import RightSection from './components/rightSection'
import NavBar from '@/components/layout/NavBar'
import platformKey from '@/helpers/getPlatformKey'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import { usePopstateListener } from '@/composables'

const componentSection = {
  [SOURCE_VERBATIM]: Verbatim,
  [SOURCE_BIBTEX]: Bibtex,
  [SOURCE_HUMAN]: Human
}

defineOptions({
  name: 'NewSource'
})

const store = useSourceStore()
const settings = useSettingStore()
const panelSearch = ref(null)

const shortcuts = ref([
  {
    keys: [platformKey(), 's'],
    handler() {
      saveSource()
    }
  },
  {
    keys: [platformKey(), 'n'],
    handler() {
      reset()
    }
  },
  {
    keys: ['Alt', 'f'],
    handler() {
      panelSearch.value?.focusSearch()
    }
  }
])

useHotkey(shortcuts.value)

const isUnsaved = computed(() => store.source.isUnsaved)

const isCrossRefModalVisible = ref(false)
const isBibtexModalVisible = ref(false)

function loadSourceFromParams() {
  const urlParams = new URLSearchParams(window.location.search)
  const sourceId = urlParams.get('source_id')

  if (/^\d+$/.test(sourceId)) {
    store.loadSource(sourceId)
  } else {
    store.reset()
  }
}

onMounted(() => {
  TW.workbench.keyboard.createLegend(`${platformKey()}+s`, 'Save', 'New source')
  TW.workbench.keyboard.createLegend(`${platformKey()}+n`, 'New', 'New source')
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+c`,
    'Clone source',
    'New source'
  )
  TW.workbench.keyboard.createLegend('Alt+f', 'Search', 'New source')

  loadSourceFromParams()
})

usePopstateListener(loadSourceFromParams)

function isSafeToDiscardChanges() {
  return (
    !isUnsaved.value ||
    (isUnsaved.value &&
      window.confirm(
        'You have unsaved changes. If you continue, your changes will be lost. Do you want to proceed?'
      ))
  )
}

function reset() {
  if (isSafeToDiscardChanges()) {
    store.reset()
  }
}

function saveSource() {
  if (!store.isSaveAvailable) return
  store.save()
}

function showBibTexForm() {
  if (isSafeToDiscardChanges()) {
    store.reset()
    isBibtexModalVisible.value = true
  }
}

function showCrossRefForm() {
  if (isSafeToDiscardChanges()) {
    store.reset()
    isCrossRefModalVisible.value = true
  }
}

async function convert() {
  settings.isConverting = true
  await store.convertToBibtex()
  settings.isConverting = false
}
</script>

<style scoped>
.button-size {
  width: 100px;
}

.nav__buttons {
  display: flex;
  flex-wrap: wrap;
  flex-direction: row;
  justify-content: end;
  align-items: center;
}

@media (min-width: 1520px) {
  .nav__buttons {
    min-width: 800px;
  }

  .nav__source-buttons {
    min-width: 150px;
  }
}

:deep(.vue-autocomplete-input) {
  width: 500px;
}
</style>
