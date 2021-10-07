<template>
  <block-layout
    anchor="original-combination">
    <template #header>
      <h3>Subsequent combination</h3>
    </template>
    <template #body>
      <combination-current/>
      <combination-rank
        v-for="(group, groupName) in RANK_LIST"
        :key="groupName"
        v-model="combination"
        :nomenclature-group="groupName"
        :rank-group="group"
        :options="{
          animation: 150,
          filter: '.item-filter'
        }"
        :group="{
          name: groupName,
          put: [groupName],
          pull: false
        }"
        @onUpdate="saveCombination"
      />
      <display-list
        :list="combinationList"
        label="cached_html"
        @delete="store.dispatch(ActionNames.RemoveCombination, $event.id)"
      />
    </template>
  </block-layout>
</template>

<script setup>

import { ref, computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters.js'
import { ActionNames } from '../../store/actions/actions.js'
import { RANK_LIST } from '../../const/rankList.js'
import DisplayList from 'components/displayList.vue'
import BlockLayout from 'components/layout/BlockLayout.vue'
import CombinationRank from './CombinationRank.vue'
import CombinationCurrent from './CombinationCurrent.vue'

const store = useStore()
const combination = ref({})
const combinationList = computed(() => store.getters[GetterNames.GetCombinations])
const currentCombination = ref()

const saveCombination = data => {
  const combObj = Object.assign({},
    { id: currentCombination.value?.id },
    ...Object.entries(data).map(([rank, taxon]) => ({ [`${rank}_id`]: taxon?.id || null }))
  )

  store.dispatch(ActionNames.CreateCombination, combObj).then(newCombination => {
    currentCombination.value = newCombination
  })
}

</script>
