<template>
  <div>
    <NavBar
      class="relative"
      navbar-class="panel content rounded-tl-none rounded-tr-none"
    >
      <div class="flex-separate full_width">
        <div class="middle gap-small">
          <div class="margin-small-right">
            <PanelSearch ref="panelSearch" />
          </div>
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
          <UnsavedIndicator v-if="isUnsaved" />
          <VBtn
            medium
            color="create"
            :disabled="!store.isSaveAvailable"
            @click="saveSource"
          >
            Save
          </VBtn>
          <CloneSource />
          |
          <VBtn
            v-if="store.source.type === SOURCE_VERBATIM && store.source.id"
            medium
            color="primary"
            @click="convert"
          >
            To BibTeX
          </VBtn>
          <VBtn
            medium
            color="primary"
            v-help.section.navBar.crossRef
            @click="showCrossRefForm"
          >
            CrossRef
          </VBtn>
          <VBtn
            medium
            color="primary"
            @click="showBibTexForm"
          >
            BibTeX
          </VBtn>

          <VBtn
            medium
            color="primary"
            @click="reset"
          >
            New
          </VBtn>
          |
          <VRecent />
          <SourceSettings />
          <VMenu title="Menu">
            <VMenuItem :href="RouteNames.SourceHub">
              Back to source hub
            </VMenuItem>
          </VMenu>
        </div>
      </div>
      <Autosave
        :disabled="!settings.autosave"
        style="bottom: 0px; left: 0px"
        class="position-absolute full_width"
      />
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
import CloneSource from './components/cloneSource.vue'
import UnsavedIndicator from '@/components/ui/UnsavedIndicator/UnsavedIndicator.vue'
import VPin from '@/components/ui/Button/ButtonPin.vue'
import CitationTotal from './components/CitationTotal.vue'

import VBtn from '@/components/ui/VBtn/index.vue'
import VRecent from './components/recent.vue'
import PanelSearch from './components/PanelSearch.vue'
import SourceSettings from './components/SourceSettings.vue'
import VMenu from '@/components/ui/VMenu/VMenu.vue'
import VMenuItem from '@/components/ui/VMenu/VMenuItem.vue'
import RightSection from './components/rightSection'
import NavBar from '@/components/layout/NavBar.vue'
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
    keys: [platformKey(), 'f'],
    preventDefault: true,
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
