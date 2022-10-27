<template>
  <PanelContainer title="Darwin core">
    <TableAttributes :items="list" />
  </PanelContainer>
</template>

<script setup>
import { PRIORITIZE_ATTRIBUTES } from '../../constants/darwinCode.js'
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useStore()
const dwcItems = computed(() => store.getters[GetterNames.GetDwc])

const list = computed(() => {
  const entries = Object.entries(dwcItems.value)

  entries.sort((a, b) => {
    const index1 = PRIORITIZE_ATTRIBUTES.indexOf(a[0])
    const index2 = PRIORITIZE_ATTRIBUTES.indexOf(b[0])

    return (index1 > -1 ? index1 : Infinity) - (index2 > -1 ? index2 : Infinity)
  })

  return Object.fromEntries(entries)
})
</script>
