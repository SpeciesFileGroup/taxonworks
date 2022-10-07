<template>
  <div class="panel panel__content">
    <h3 class="panel__title">
      Collecting events
    </h3>
    <TableAttributes :items="collectingEvent" />
  </div>
</template>

<script setup>
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../../store/getters/getters'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useStore()
const collectingEvent = computed(() => store.getters[GetterNames.GetCollectingEvent])
</script>
