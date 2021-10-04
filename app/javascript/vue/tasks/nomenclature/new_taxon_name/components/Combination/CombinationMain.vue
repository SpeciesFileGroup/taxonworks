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
            put: true,
            pull: false
          },
          filter: '.item-filter'
        }"
      />
    </template>
  </block-layout>
</template>

<script setup>

import {
  ref,
  computed,
  watch
} from 'vue'

import BlockLayout from 'components/layout/BlockLayout.vue'
import CombinationRank from './CombinationRank.vue'
import { Combination } from 'routes/endpoints'

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

const combination = ref({
  genus: undefined,
  subgenus: undefined,
  species: undefined,
  subspecies: undefined,
  variety: undefined,
  form: undefined
})

const makeCombination = data => Object.fromEntries(Object.entries(data).map(([rank, value]) => [`${rank}_id`, value]))

const createCombination = data => {
  const combination = makeCombination(data)

  Combination.create({ combination })
}

</script>