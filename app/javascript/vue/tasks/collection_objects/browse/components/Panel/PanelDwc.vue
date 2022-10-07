<template>
  <PanelContainer title="Dwc">
    <TableAttributes :items="dwcItems" />
  </PanelContainer>
</template>

<script setup>
import { computed } from 'vue'
import { useStore } from 'vuex'
import { GetterNames } from '../../store/getters/getters'
import PanelContainer from './PanelContainer.vue'
import TableAttributes from '../Table/TableAttributes.vue'

const store = useStore()
const dwcItems = computed(() => store.getters[GetterNames.GetDwc])
</script>
