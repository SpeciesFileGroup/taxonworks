<template>
  <div class="panel panel__content">
    <h3 class="panel__title">
      Attributes
    </h3>
    <TableAttributes :items="list" />
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import { PRIORITIZE, HIDE_ATTRIBUTES } from '../../constants/collectingEvents.js'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useStore()
const collectingEvent = computed(() => store.getters[GetterNames.GetCollectingEvent])

const list = computed(() => {
  const entries = Object.entries(collectingEvent.value)
  const filteredList = entries.filter(([property, _]) => !HIDE_ATTRIBUTES.includes(property))

  filteredList.sort((a, b) => {
    const index1 = PRIORITIZE.indexOf(a[0])
    const index2 = PRIORITIZE.indexOf(b[0])

    return (index1 > -1 ? index1 : Infinity) - (index2 > -1 ? index2 : Infinity)
  })

  return Object.fromEntries(filteredList)
})

</script>
