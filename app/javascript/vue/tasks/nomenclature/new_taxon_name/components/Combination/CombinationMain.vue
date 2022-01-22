<template>
  <block-layout
    :spinner="!taxon.id"
    anchor="subsequent-combination">
    <template #header>
      <h3>Subsequent combination</h3>
    </template>
    <template #body>
      <combination-current
        v-if="!isCurrentTaxonInCombination"
        :combination-ranks="combinationRanks"
        @onSet="combination = $event"
      />
      <combination-rank
        v-for="(group, groupName) in combinationRanks"
        :key="groupName"
        v-model="combination"
        :nomenclature-group="groupName"
        :rank-group="Object.keys(group)"
        :disabled="!isCurrentTaxonInCombination"
        :options="{
          animation: 150,
          filter: '.item-filter'
        }"
        :group="{
          name: groupName,
          put: [groupName],
          pull: false
        }"
      />

      <div class="original-combination margin-medium-top margin-medium-bottom">
        <div class="rank-name-label"/>
        <combination-verbatim v-model="currentCombination.verbatim_name"/>
      </div>

      <combination-citation
        :taxon="taxon"
        v-model="citationData"/>
      <hr>

      <template v-if="isBotanyCode">
        <h3>Classification</h3>
        <classification-main
          :taxon-id="taxon.id"
          @select="addClassification"
        />

        <display-list
          v-if="currentCombination.id"
          :list="classifications"
          label="object_tag"
          annotator
          @delete="removeClassification"
        />
        <display-list
          v-else
          :list="queueClassification"
          label="name"
          :delete-warning="false"
          @delete-index="queueClassification.splice($event, 1)"
          soft-delete
        />
      </template>

      <div class="margin-medium-top">
        <v-btn
          class="margin-small-right"
          color="create"
          medium
          :disabled="!isCurrentTaxonInCombination"
          @click="saveCombination"
        >
          {{
            currentCombination.id
              ? 'Update'
              : 'Create'
          }}
        </v-btn>
        <v-btn
          color="primary"
          medium
          @click="newCombination"
        >
          New
        </v-btn>
      </div>
      <hr>
      <combination-list
        :list="combinationList"
        @edit="loadCombination"
        @delete="removeCombination"
      />
    </template>
  </block-layout>
</template>

<script setup>

import { ref, computed, reactive, watch } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters.js'
import { ActionNames } from '../../store/actions/actions.js'
import {
  combinationType,
  combinationIcnType
} from '../../const/originalCombinationTypes'
import {
  COMBINATION,
  NOMENCLATURE_CODE_BOTANY
} from 'constants/index.js'
import { addToArray, removeFromArray } from 'helpers/arrays.js'
import { TaxonNameClassification } from 'routes/endpoints'
import VBtn from 'components/ui/VBtn/index.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import CombinationRank from './CombinationRank.vue'
import CombinationCurrent from './CombinationCurrent.vue'
import CombinationVerbatim from './CombinationVerbatim.vue'
import CombinationCitation from './Author/AuthorMain.vue'
import CombinationList from './CombinationList.vue'
import ClassificationMain from '../Classification/ClassificationMain.vue'
import makeCitationObject from 'factory/Citation.js'
import DisplayList from 'components/displayList.vue'

const store = useStore()
const combination = ref({})
const combinationList = computed(() => store.getters[GetterNames.GetCombinations])
const taxon = computed(() => store.getters[GetterNames.GetTaxon])
const currentCombination = ref({})
const currentCombinationId = computed(() => currentCombination.value.id)
const isCurrentTaxonInCombination = computed(() => !!Object.entries(combination.value).find(([_, protonym]) => protonym?.id === taxon.value.id))
const isBotanyCode = computed(() => store.getters[GetterNames.GetTaxon].nomenclatural_code === NOMENCLATURE_CODE_BOTANY)
const nomenclatureRanks = computed(() => isBotanyCode.value
  ? combinationIcnType
  : combinationType
)
const isGenusGroup = computed(() => Object.keys(nomenclatureRanks.value.genusGroup).includes(taxon.value.rank))
const combinationRanks = computed(() => isGenusGroup.value
  ? { genusGroup: nomenclatureRanks.value.genusGroup }
  : nomenclatureRanks.value
)

const saveCombination = () => {
  const combObj = Object.assign({},
    {
      id: currentCombination.value.id,
      verbatim_name: currentCombination.value.verbatim_name,
      ...citationData
    },
    ...removeOldRelationships(combination.value),
    ...makeCombinationParams()
  )

  store.dispatch(ActionNames.CreateCombination, combObj).then(body => {
    combination.value = {}
    currentCombination.value = {}
    setCitationData()
    processQueueCombination(body.id)
  })
}

const removeOldRelationships = protonyms => {
  const removeRanks = []
  const oldProtonyms = currentCombination.value.protonyms

  for (const rank in oldProtonyms) {
    const oldTaxon = oldProtonyms[rank]
    const newTaxon = protonyms[rank]

    if (oldTaxon && !newTaxon) {
      removeRanks.push({
        [`${rank}_taxon_name_relationship_attributes`]: {
          id: oldTaxon.taxon_name_relationship_id,
          _destroy: true
        }
      })
    }
  }

  return removeRanks
}

const makeCombinationParams = () => Object.entries(combination.value).map(([rank, taxon]) => ({ [`${rank}_id`]: taxon?.id || null }))

const newCombination = () => {
  combination.value = {}
  currentCombination.value = {}
  queueClassification.value = []
  setCitationData()
}

const loadCombination = data => {
  currentCombination.value = { ...data }
  combination.value = data.protonyms
  setCitationData(data)
}

const removeCombination = data => {
  if (data.id === currentCombination.value.id) {
    currentCombination.value = {}
    combination.value = {}
  }

  store.dispatch(ActionNames.RemoveCombination, data.id)
}

// ======================================
// Citation
// ======================================

const citationData = reactive({
  origin_citation_attributes: makeCitationObject(COMBINATION),
  verbatim_author: undefined,
  year_of_publication: undefined,
  roles_attributes: []
})

const setCitationData = (combination = {}) => {
  citationData.verbatim_author = combination.verbatim_author
  citationData.year_of_publication = combination.year_of_publication
  citationData.roles_attributes = combination.taxon_name_author_roles || []
  citationData.origin_citation_attributes = combination.origin_citation
    ? {
        id: combination.origin_citation.id,
        source_id: combination.origin_citation.source.id,
        pages: combination.origin_citation.pages,
        global_id: combination.origin_citation.global_id
      }
    : makeCitationObject(COMBINATION)
}

// ======================================
// Classifications
// ======================================

const classifications = ref([])
const queueClassification = ref([])

const addClassification = type => {
  queueClassification.value.push(type)
}

const removeClassification = item => {
  TaxonNameClassification.destroy(item.id).then(_ => {
    removeFromArray(classifications.value, item)
  })
}

const processQueueCombination = combinationId => {
  if (!queueClassification.value.length) { return }

  const promise = queueClassification.value.map(({ type }) =>
    TaxonNameClassification.create({
      taxon_name_classification: {
        taxon_name_id: combinationId,
        type
      }
    }).then(({ body }) => {
      addToArray(classifications.value, body)
    })
  )

  Promise.allSettled(promise).then(_ => {
    queueClassification.value = []
  })
}

watch(queueClassification, _ => {
  if (currentCombinationId.value) {
    processQueueCombination(currentCombinationId.value)
  }
}, { deep: true })

watch(currentCombinationId, async newId => {
  classifications.value = newId
    ? (await TaxonNameClassification.where({ taxon_name_id: newId })).body
    : []

  queueClassification.value = []
})

</script>
