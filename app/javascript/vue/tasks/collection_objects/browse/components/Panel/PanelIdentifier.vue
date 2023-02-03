<template>
  <PanelContainer title="Identifiers">
    <TableAttributes
      :header="['Identifier', 'On']"
      :items="identifiers"
    />
  </PanelContainer>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useStore()
const identifiers = computed(() => {
  const list = store.getters[GetterNames.GetIdentifiers]
  const newlist = {}

  for (const key in list) {
    list[key].forEach(identifier => {
      newlist[identifier.objectTag] = key
    })
  }

  return newlist
})
</script>
