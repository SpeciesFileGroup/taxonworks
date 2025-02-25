<template>
  <PanelContainer title="Identifiers">
    <TableAttributes
      :header="['Identifier', 'On']"
      :items="identifiers"
    />
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '@/tasks/collection_objects/browse/components/Table/TableAttributes.vue'
import useIdentifierStore from '../../store/identifiers.js'

const store = useIdentifierStore()

const identifiers = computed(() => {
  return Object.fromEntries(
    store.identifiers.map((item) => [item.identifier, item.type])
  )
})
</script>
