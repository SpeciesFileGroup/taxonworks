<template>
  <TableAttributes
    :items="list"
    filter-attributes
  />
</template>

<script setup>
import { computed } from 'vue'
import {
  PRIORITIZE_ATTRIBUTES,
  HIDE_ATTRIBUTES
} from '../../constants/collectingEvents.js'
import useCollectingEventStore from '../../store/collectingEvent.js'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useCollectingEventStore()

const list = computed(() => {
  const entries = Object.entries(store.collectingEvent)
  const filteredList = entries.filter(
    ([property, _]) => !HIDE_ATTRIBUTES.includes(property)
  )

  filteredList.sort((a, b) => {
    const index1 = PRIORITIZE_ATTRIBUTES.indexOf(a[0])
    const index2 = PRIORITIZE_ATTRIBUTES.indexOf(b[0])

    return (index1 > -1 ? index1 : Infinity) - (index2 > -1 ? index2 : Infinity)
  })

  return Object.fromEntries(filteredList)
})
</script>
