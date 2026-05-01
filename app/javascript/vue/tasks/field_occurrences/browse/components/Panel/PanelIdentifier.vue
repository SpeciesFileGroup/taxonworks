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

const INAT_OBSERVATION_TYPE = 'Identifier::Global::Uuid::InaturalistObservation'
const INAT_BASE_URL = 'https://www.inaturalist.org/observations/'

const identifiers = computed(() => {
  return Object.fromEntries(
    store.identifiers.map((item) => {
      const display =
        item.type === INAT_OBSERVATION_TYPE
          ? `<a href="${INAT_BASE_URL}${item.identifier}" target="_blank">${item.identifier}</a>`
          : item.identifier
      return [display, item.type]
    })
  )
})
</script>
