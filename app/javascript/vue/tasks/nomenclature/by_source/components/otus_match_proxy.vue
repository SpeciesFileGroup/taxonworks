<template>
  <div>
    <h2>OTU summary</h2>
    <otu-table-component :list="list"/>
  </div>
</template>
<script setup>

import OtuTableComponent from './tables/otu_table.vue'
import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters';

const store = useStore()
const list = computed(() => store.getters[GetterNames.GetOtuList])

</script>
