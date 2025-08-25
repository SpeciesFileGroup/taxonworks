<template>
  <BlockLayout>
    <template #header>
      <h3>Rows</h3>
    </template>
    <template #body>
      <div>
        <VSpinner v-if="loadingTag" />
        <fieldset class="separate-bottom">
          <legend>Tag/Keyword</legend>
          <SmartSelector
            :options="smartOptions"
            v-model="view"
            name="rows-smart"
          />
          <component
            v-if="currentComponent"
            :list="selectorLists[view]"
            :is="currentComponent"
            @send="create"
          />
          <VAutocomplete
            v-else
            url="/controlled_vocabulary_terms/autocomplete"
            param="term"
            label="label_html"
            :clear-after="true"
            placeholder="Search a keyword"
            min="2"
            @get-item="create"
          />
        </fieldset>
      </div>
      <div>
        <VSpinner v-if="loadingTaxon" />
        <fieldset>
          <legend>Taxon name</legend>
          <SmartSelector
            :options="smartTaxon"
            v-model="viewTaxonName"
            name="rows-smart-taxon"
          />
          <template v-if="smartTaxon.length">
            <SmartTaxonList
              class="no_bullets"
              v-if="viewTaxonName !== 'search'"
              :created-list="rowsListDynamic"
              :list="listTaxon[viewTaxonName]"
              value-compare="taxon_name_id"
              @selected="createTaxon"
            />
            <VAutocomplete
              v-else
              url="/taxon_names/autocomplete"
              param="term"
              label="label_html"
              :clear-after="true"
              placeholder="Search taxon names..."
              @getItem="createTaxon"
              min="2"
              @get-item="createTaxon"
            />
          </template>
        </fieldset>
      </div>
    </template>
  </BlockLayout>
</template>

<script setup>
import { TAXON_NAME, CONTROLLED_VOCABULARY_TERM } from '@/constants/index.js'
import { computed, ref } from 'vue'
import { useStore } from 'vuex'
import { GetSmartSelector } from '../../request/resources'
import { ActionNames } from '../../store/actions/actions'
import { GetterNames } from '../../store/getters/getters'
import {
  default as quick,
  default as recent,
  default as pinboard
} from '../shared/tag_list'
import SmartSelector from '../shared/smartSelector'
import SmartTaxonList from './dynamic/smartList'
import VAutocomplete from '@/components/ui/Autocomplete'
import VSpinner from '@/components/ui/VSpinner'
import BlockLayout from '@/components/layout/BlockLayout.vue'
import ObservationTypes from '../../const/types.js'

const COMPONENTS = { quick, recent, pinboard }

const store = useStore()
const currentComponent = computed(() => COMPONENTS[view.value])
const matrixId = computed(() => store.getters[GetterNames.GetMatrix].id)
const rowsListDynamic = computed(
  () => store.getters[GetterNames.GetMatrixRowsDynamic]
)

const smartOptions = ref([])
const smartTaxon = ref([])
const selectorLists = ref()
const listTaxon = ref()
const view = ref()
const viewTaxonName = ref('search')
const loadingTag = ref(true)
const loadingTaxon = ref(true)

GetSmartSelector('keywords').then(({ body }) => {
  smartOptions.value = Object.keys(body)
  selectorLists.value = body
  loadingTag.value = false
  smartOptions.value.push('search')
})

GetSmartSelector('taxon_names').then(({ body }) => {
  smartTaxon.value = [...Object.keys(body), 'search']
  listTaxon.value = body
  loadingTaxon.value = false
})

function create(item) {
  store.dispatch(ActionNames.CreateRowItem, {
    observation_object_id: item.id,
    observation_object_type: CONTROLLED_VOCABULARY_TERM,
    observation_matrix_id: matrixId.value,
    type: ObservationTypes.Row.Tag
  })
}

function createTaxon(item) {
  store.dispatch(ActionNames.CreateRowItem, {
    observation_object_id: item.id,
    observation_object_type: TAXON_NAME,
    observation_matrix_id: matrixId.value,
    type: ObservationTypes.Row.TaxonName
  })
}
</script>
