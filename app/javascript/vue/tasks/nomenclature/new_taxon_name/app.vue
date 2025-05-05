<template>
  <div id="new_taxon_name_task">
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
      <nav-header />
      <div class="flexbox horizontal-center-content align-start">
        <div class="ccenter item">
          <spinner
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
        <div
          v-if="taxon.id"
          class="cright item margin-medium-left"
        >
          <div
            id="cright-panel"
            ref="rightPanelRef"
          >
            <div class="panel content margin-medium-bottom">
              <autocomplete
                id="taxonname-autocomplete-search"
                url="/taxon_names/autocomplete"
                param="term"
                :add-params="{ 'type[]': 'Protonym' }"
                label="label_html"
                placeholder="Search a taxon name..."
                @get-item="loadTaxon"
                clear-after
              />
            </div>
            <check-changes />
            <taxon-name-box class="separate-bottom" />
            <soft-validation
              v-if="checkSoftValidation"
              class="separate-top"
              :validations="validations"
            />
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import Autocomplete from '@/components/ui/Autocomplete'
import NavHeader from './components/navHeader.vue'
import TaxonNameBox from './components/taxonNameBox.vue'
import CheckChanges from './components/checkChanges.vue'
import SoftValidation from '@/components/soft_validations/panel.vue'
import Spinner from '@/components/ui/VSpinner.vue'
import platformKey from '@/helpers/getPlatformKey'
import { useHotkey } from '@/composables'
import { SectionComponents } from './const/components.js'
import { convertType } from '@/helpers/types.js'
import { GetterNames } from './store/getters/getters'
import { MutationNames } from './store/mutations/mutations'
import { ActionNames } from './store/actions/actions'
import { computed, ref, onMounted } from 'vue'
import { useStore } from 'vuex'

defineOptions({
  name: 'NewTaxonName'
})

const store = useStore()

const rightPanelRef = ref(null)
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

const validations = computed(() => store.getters[GetterNames.GetSoftValidation])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const checkSoftValidation = computed(
  () =>
    validations.value.taxon_name.list.length ||
    validations.value.taxonStatusList.list.length ||
    validations.value.taxonRelationshipList.list.length
)

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

  window.addEventListener('scroll', scrollBox)

  initLoad().then(() => {
    if (/^\d+$/.test(taxonId)) {
      store
        .dispatch(ActionNames.LoadTaxonName, taxonId)
        .then((taxon) => {
          store.dispatch(ActionNames.LoadTaxonStatus, taxonId)
          store.dispatch(ActionNames.LoadTaxonRelationships, taxonId)
          store.dispatch(ActionNames.LoadOriginalCombination, taxonId)
          store.dispatch(ActionNames.LoadCombinations, taxon.id)
        })
        .finally(() => {
          isLoading.value = false
        })
    } else {
      isLoading.value = false
    }
  })

  addShortcutsDescription()
})

function scrollBox() {
  const element = rightPanelRef.value
  const softValidationContainer = document.querySelector(
    '#new_taxon_name_task .soft-validation-box'
  )
  if (softValidationContainer) {
    const innerHeight = window.innerHeight
    const elementRect = softValidationContainer.getBoundingClientRect()

    softValidationContainer.style.maxHeight = `${
      innerHeight - elementRect.top - 20
    }px`
  }
  if (element) {
    if (
      (window.pageYOffset ||
        document.documentElement.scrollTop ||
        document.body.scrollTop ||
        0) > 154
    ) {
      element.classList.add('cright-fixed-top')
    } else {
      element.classList.remove('cright-fixed-top')
    }
  }
}

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
#new_taxon_name_task {
  flex-direction: column-reverse;
  margin: 0 auto;
  margin-top: 1em;
  max-width: 1240px;

  .autocomplete-search-bar {
    input {
      width: 500px;
    }
  }

  .navbar-button {
    min-width: 80px;
    width: 100%;
  }

  .cleft,
  .cright {
    min-width: 350px;
    max-width: 350px;
    width: 300px;
  }
  .ccenter {
    max-width: 1240px;
  }
  #cright-panel {
    width: 350px;
    max-width: 350px;
  }
  .cright-fixed-top {
    top: 76px;
    width: 1240px;
    z-index: 200;
    position: fixed;
  }
  .anchor {
    display: block;
    height: 65px;
    margin-top: -65px;
    visibility: hidden;
  }
  hr {
    height: 1px;
    color: #f5f5f5;
    background: #f5f5f5;
    font-size: 0;
    margin: 15px;
    border: 0;
  }
}
</style>
