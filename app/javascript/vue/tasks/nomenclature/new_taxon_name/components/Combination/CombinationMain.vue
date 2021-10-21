<template>
  <block-layout
    anchor="original-combination">
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

      <div class="original-combination margin-medium-top">
        <div class="rank-name-label"/>
        <combination-verbatim v-model="currentCombination.verbatim_name"/>
      </div>

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
      <display-list
        :list="combinationList"
        label="object_label"
        edit
        annotator
        @edit="loadCombination"
        @delete="removeCombination"
      />
    </template>
  </block-layout>
</template>

<script setup>

import { ref, computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters.js'
import { ActionNames } from '../../store/actions/actions.js'
import {
  combinationType,
  combinationIcnType
} from '../../const/originalCombinationTypes'
import VBtn from 'components/ui/VBtn/index.vue'
import DisplayList from 'components/displayList.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import CombinationRank from './CombinationRank.vue'
import CombinationCurrent from './CombinationCurrent.vue'
import CombinationVerbatim from './CombinationVerbatim.vue'

const store = useStore()
const combination = ref({})
const combinationList = computed(() => store.getters[GetterNames.GetCombinations])
const taxonId = computed(() => store.getters[GetterNames.GetTaxon].id)
const currentCombination = ref({})
const isCurrentTaxonInCombination = computed(() => !!Object.entries(combination.value).find(([_, taxon]) => taxon?.id === taxonId.value))
const combinationRanks = computed(() =>
  store.getters[GetterNames.GetTaxon].nomenclatural_code === 'icn'
    ? combinationIcnType
    : combinationType
)

const saveCombination = () => {
  const combObj = Object.assign({},
    {
      id: currentCombination.value.id,
      verbatim_name: currentCombination.value.verbatim_name
    },
    ...removeOldRelationships(combination.value),
    ...makeCombinationParams()
  )

  store.dispatch(ActionNames.CreateCombination, combObj).then(_ => {
    combination.value = {}
    currentCombination.value = {}
  })
}

const removeOldRelationships = protonyms => {
  const removeRanks = []
  const oldProtonyms = currentCombination.value.protonyms

  for (const rank in oldProtonyms) {
    const taxon = oldProtonyms[rank]
    const newTaxon = protonyms[rank]

    if (taxon && !newTaxon) {
      removeRanks.push({
        [`${rank}_taxon_name_relationship_attributes`]: { 
          id: oldProtonyms[rank].taxon_name_relationship_id,
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
}

const loadCombination = data => {
  currentCombination.value = { ...data }
  combination.value = data.protonyms
}

const removeCombination = data => {
  if (data.id === currentCombination.value.id) {
    currentCombination.value = {}
    combination.value = {}
  }

  store.dispatch(ActionNames.RemoveCombination, data.id)
}

</script>
