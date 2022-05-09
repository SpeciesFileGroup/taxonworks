<template>
  <div>
    <h2>OTU summary</h2>
    <TableOtu
      class="full_width"
      :list="list"
    />
  </div>
</template>
<script setup>

import { useStore } from 'vuex'
import { computed } from 'vue'
import { GetterNames } from '../store/getters/getters'
import TableOtu from './tables/TableOtu.vue'

const store = useStore()
const list = computed(() => store.getters[GetterNames.GetOtuList])

</script>
