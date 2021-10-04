<template>
  <block-layout
    anchor="original-combination">
    <template #header>
      <h3>Subsequent combination</h3>
    </template>
    <template #body>
      <combination-rank
        v-for="(group, groupName) in RANK_LIST"
        :key="groupName"
        v-model="combination"
        :nomenclature-group="groupName"
        :rank-group="group"
        :options="{
          animation: 150,
          group: {
            name: 'subsequentCombination',
            put: isGenus,
            pull: false
          },
          filter: '.item-filter'
        }"
        @update="updateCombination"
      />
      <display-list
        :list="combinationList"
        label="cached_html"
      />
    </template>
  </block-layout>
</template>

<script setup>

import { ref, computed, watch } from 'vue'
import { useStore } from 'vuex'
import { Combination } from 'routes/endpoints'
import { GetterNames } from '../../store/getters/getters.js'
import DisplayList from 'components/displayList.vue'

import BlockLayout from 'components/layout/BlockLayout.vue'
import CombinationRank from './CombinationRank.vue'

const RANK_LIST = {
  genusGroup: [
    'genus',
    'subgenus'
  ],
  speciesGroup: [
    'species',
    'subspecies',
    'variety',
    'form'
  ]
}

const store = useStore()
const combination = ref({})
const taxonId = computed(() => store.getters[GetterNames.GetTaxon].id)
const isGenus = computed(() => store.getters[GetterNames.GetTaxon].rank_string.includes('GenusGroup'))
const combinationList = ref([])

const saveCombination = data => {
  const combination = {
    ...makeCombination(data)
  }

  console.log(combination)

  Combination.create({ combination })
}

watch(() => taxonId.value, () => {
  Combination.where({ protonym_id: taxonId.value }).then(({ body }) => {
    combination.value = body
  })
})

</script>