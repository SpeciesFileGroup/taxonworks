<template>
  <div>
    <div class="flex-separate middle">
      <h1>New source</h1>
      <ul class="context-menu">
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
          <a href="/tasks/sources/hub">Back to source hub</a>
        </li>
      </ul>
    </div>
    <NavBar class="source-navbar">
      <div class="flex-separate full_width">
        <div class="middle gap-small">
          <PanelSearch />
          <span
            v-if="source.id"
            class="word_break"
            v-html="source.cached"
          />
          <span v-else>New record</span>
        </div>
        <div class="nav__buttons gap-small">
          <VIcon
            v-if="unsave"
            name="attention"
            color="attention"
            title="You have unsaved changes."
          />
          <button
            class="button normal-input button-submit button-size"
            type="button"
            :disabled="source.type === SOURCE_BIBTEX && !source.bibtex_type"
            @click="saveSource"
          >
            Save
          </button>
          <CloneSource />
          |
          <button
            v-if="source.type === SOURCE_VERBATIM && source.id"
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
            :disabled="source.id"
            @click="() => (isModalVisible = true)"
          >
            CrossRef
          </button>
          <button
            type="button"
            class="button normal-input button-default button-size"
            :disabled="source.id"
            @click="() => (showBibtex = true)"
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
      </div>
    </NavBar>
    <div class="horizontal-left-content align-start">
      <BlockLayout class="full_width">
        <template #header>
          <div class="flex-separate middle full_width">
            <h3>Source</h3>

            <div class="horizontal-right-content gap-small">
              <VPin
                class="circle-button"
                type="Source"
                :object-id="source.id"
              />
              <AddSource
                :project-source-id="source.project_source_id"
                :id="source.id"
              />
              <RadialAnnotator :global-id="source.global_id" />
              <RadialObject :global-id="source.global_id" />
            </div>
          </div>
        </template>
        <template #body>
          <div class="full_width panel content">
            <SourceType class="margin-medium-bottom" />
            <component :is="componentSection[source.type]" />
          </div>
        </template>
      </BlockLayout>
      <RightSection class="margin-medium-left" />
    </div>
    <CrossRef
      v-if="isModalVisible"
      @close="() => (isModalVisible = false)"
    />
    <BibtexButton
      v-if="showBibtex"
      @close="() => (showBibtex = false)"
    />
    <VSpinner
      v-if="settings.isConverting"
      full-screen
      :logo-size="{ width: '100px', height: '100px' }"
      legend="Converting verbatim to BiBTeX..."
    />
  </div>
</template>

<script setup>
import { computed, ref, watch, onMounted } from 'vue'
import { useStore } from 'vuex'
import { User } from '@/routes/endpoints'
import { GetterNames } from './store/getters/getters'
import { ActionNames } from './store/actions/actions'
import { MutationNames } from './store/mutations/mutations'
import { SOURCE_BIBTEX, SOURCE_HUMAN, SOURCE_VERBATIM } from '@/constants'

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

import PanelSearch from './components/PanelSearch.vue'
import RightSection from './components/rightSection'
import NavBar from '@/components/layout/NavBar'
import platformKey from '@/helpers/getPlatformKey'
import { useHotkey } from '@/composables'
import BlockLayout from '@/components/layout/BlockLayout.vue'

const componentSection = {
  [SOURCE_VERBATIM]: Verbatim,
  [SOURCE_BIBTEX]: Bibtex,
  [SOURCE_HUMAN]: Human
}

defineOptions({
  name: 'NewSource'
})

const store = useStore()

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
  }
])

useHotkey(shortcuts.value)

const source = computed(() => store.getters[GetterNames.GetSource])
const settings = computed({
  get() {
    return store.getters[GetterNames.GetSettings]
  },
  set(value) {
    store.commit(MutationNames.SetSettings, value)
  }
})

const unsave = computed(() => settings.value.lastSave < settings.value.lastEdit)

const isModalVisible = ref(false)
const showBibtex = ref(false)

watch(
  source,
  (newVal, oldVal) => {
    if (newVal.id === oldVal.id) {
      settings.value.lastEdit = Date.now()
    }
  },
  { deep: true }
)

onMounted(() => {
  TW.workbench.keyboard.createLegend(`${platformKey()}+s`, 'Save', 'New source')
  TW.workbench.keyboard.createLegend(`${platformKey()}+n`, 'New', 'New source')
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+c`,
    'Clone source',
    'New source'
  )

  const urlParams = new URLSearchParams(window.location.search)
  const sourceId = urlParams.get('source_id')

  if (/^\d+$/.test(sourceId)) {
    store.dispatch(ActionNames.LoadSource, sourceId)
  }

  User.preferences().then(({ body }) => {
    store.commit(MutationNames.SetPreferences, body)
  })
})

function reset() {
  store.dispatch(ActionNames.ResetSource)
}
function saveSource() {
  if (source.value.type === SOURCE_BIBTEX && !source.value.bibtex_type) return
  store.dispatch(ActionNames.SaveSource)
}

function convert() {
  store.dispatch(ActionNames.ConvertToBibtex)
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
</style>
