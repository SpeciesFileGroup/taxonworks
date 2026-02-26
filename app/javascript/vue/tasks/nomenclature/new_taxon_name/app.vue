<template>
  <div
    id="app-new-taxon-name"
    class="container-xl"
  >
    <div class="flex-separate middle">
      <h1>{{ taxon.id ? 'Edit' : 'New' }} taxon name</h1>
      <div class="horizontal-right-content middle">
        <label
          v-help.section.navbar.autosave
          class="horizontal-left-content middle margin-medium-right"
        >
          <input
            type="checkbox"
            v-model="isAutosaveActive"
          />
          Autosave
        </label>
        <autocomplete
          v-if="!taxon.id"
          class="autocomplete-search-bar"
          url="/taxon_names/autocomplete"
          param="term"
          :add-params="{ 'type[]': 'Protonym' }"
          label="label_html"
          placeholder="Search a taxon name..."
          clear-after
          @get-item="loadTaxon"
        />
      </div>
    </div>
    <div>
      <NavHeader />
      <div class="flexbox horizontal-center-content align-start">
        <div class="item">
          <VSpinner
            full-screen
            :legend="isLoading ? 'Loading...' : 'Saving changes...'"
            :logo-size="{ width: '100px', height: '100px' }"
            v-if="isLoading"
          />
          <template
            v-for="{ component, title, isAvailableFor } in SectionComponents"
            :key="title"
          >
            <component
              v-if="isAvailableFor(taxon)"
              class="margin-medium-bottom"
              :is="component"
            />
          </template>
        </div>
        <ColumnRight
          v-if="taxon.id"
          class="cright item margin-medium-left"
          @select-taxon="loadTaxon"
        />
      </div>
    </div>
  </div>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete'
import NavHeader from './components/navHeader.vue'
import VSpinner from '@/components/ui/VSpinner.vue'
import platformKey from '@/helpers/getPlatformKey'
import ColumnRight from './components/ColumnRight.vue'
import { useHotkey } from '@/composables'
import { SectionComponents } from './const/components.js'
import { convertType } from '@/helpers/types.js'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'
import { computed, ref, onMounted, useTemplateRef } from 'vue'
import { useStore } from 'vuex'

defineOptions({
  name: 'NewTaxonName'
})

const store = useStore()

const isLoading = ref()
const shortcuts = ref([
  {
    keys: [platformKey(), 'f'],
    preventDefault: true,
    handler() {
      focusSearch()
    }
  }
])

useHotkey(shortcuts.value)

const taxon = computed(() => store.getters[GetterNames.GetTaxon])

const isAutosaveActive = computed({
  get() {
    return store.getters[GetterNames.GetAutosave]
  },
  set(value) {
    store.commit(MutationNames.SetAutosave, value)
  }
})

onMounted(() => {
  const urlParams = new URLSearchParams(window.location.search)
  let taxonId = urlParams.get('taxon_name_id')
  const value = convertType(
    sessionStorage.getItem('task::newtaxonname::autosave')
  )

  if (value !== null) {
    isAutosaveActive.value = value
  }

  if (!taxonId) {
    taxonId = location.pathname.split('/')[4]
  }

  initLoad().then(() => {
    if (/^\d+$/.test(taxonId)) {
      isLoading.value = true
      store
        .dispatch(ActionNames.LoadTaxonName, taxonId)
        .then((taxon) => {
          store.dispatch(ActionNames.LoadTaxonStatus, taxonId)
          store.dispatch(ActionNames.LoadTaxonRelationships, taxonId)
          store.dispatch(ActionNames.LoadOriginalCombination, taxonId)
          store.dispatch(ActionNames.LoadCombinations, taxon.id)
        })
        .catch(() => {})
        .finally(() => {
          isLoading.value = false
        })
    }
  })

  addShortcutsDescription()
})

function addShortcutsDescription() {
  const TASK = 'New taxon name'
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+d`,
    'Create a child of this taxon name',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+e`,
    'Go to comprehensive specimen digitization',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+f`,
    'Move focus to search',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+l`,
    'Clone this taxon name',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+n`,
    'Create a new taxon name',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+p`,
    'Create a new taxon name with the same parent',
    TASK
  )
  TW.workbench.keyboard.createLegend(
    `${platformKey()}+s`,
    'Save taxon name changes',
    TASK
  )
}

async function initLoad() {
  const actions = [
    store.dispatch(ActionNames.LoadRanks),
    store.dispatch(ActionNames.LoadStatus),
    store.dispatch(ActionNames.LoadRelationships)
  ]

  return Promise.all(actions).then(() => {
    store.commit(MutationNames.SetInitLoad, true)
  })
}

function loadTaxon(taxon) {
  window.open(
    `/tasks/nomenclature/new_taxon_name?taxon_name_id=${taxon.id}`,
    '_self'
  )
}

function focusSearch() {
  if (taxon.value.id) {
    document.querySelector('#taxonname-autocomplete-search input').focus()
  } else {
    document.querySelector('.autocomplete-search-bar input').focus()
  }
}
</script>

<style lang="scss">
#app-new-taxon-name {
  flex-direction: column-reverse;
  margin: 0 auto;

  .autocomplete-search-bar {
    input {
      width: 500px;
    }
  }

  .navbar-button {
    min-width: 80px;
    width: 100%;
  }

  #cright-panel {
    width: 400px;
    max-width: 400px;
  }

  .anchor {
    display: block;
    height: 65px;
    margin-top: -65px;
    visibility: hidden;
  }
}
</style>
