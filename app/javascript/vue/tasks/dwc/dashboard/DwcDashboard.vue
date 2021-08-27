<template>
  <h1>DwC Dashboard</h1>
  <div>
    <graph-component :metadata="metadata"/>
    <btn-reindex />
  </div>
</template>
<script setup>

import { onBeforeMount, ref } from 'vue'
import { DwcOcurrence } from 'routes/endpoints'
import GraphComponent from './components/Graph.vue'
import BtnReindex from './components/Reindex.vue'

const metadata = ref({})

onBeforeMount(async () => {
  metadata.value = (await DwcOcurrence.metadata()).body.metadata
})

</script>
