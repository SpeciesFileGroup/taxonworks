<template>
  <TableAttributes
    :items="list"
    filter-attributes
  />
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import {
  PRIORITIZE_ATTRIBUTES,
  HIDE_ATTRIBUTES
} from '../../constants/collectingEvents.js'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useStore()
const collectingEvent = computed(() => store.getters[GetterNames.GetCollectingEvent])

const list = computed(() => {
  const entries = Object.entries(collectingEvent.value)
  const filteredList = entries.filter(([property, _]) => !HIDE_ATTRIBUTES.includes(property))

  filteredList.sort((a, b) => {
    const index1 = PRIORITIZE_ATTRIBUTES.indexOf(a[0])
    const index2 = PRIORITIZE_ATTRIBUTES.indexOf(b[0])

    return (index1 > -1 ? index1 : Infinity) - (index2 > -1 ? index2 : Infinity)
  })

  return Object.fromEntries(filteredList)
})

</script>
