<template>
  <ImportForm @submitted="onSubmitted" />
  <SummaryTable
    v-if="summary"
    :rows="summary"
    @clear="summary = null"
  />
  <RecentImports />
</template>

<script setup>
import { ref } from 'vue'
import ImportForm from './components/ImportForm.vue'
import SummaryTable from './components/SummaryTable.vue'
import RecentImports from './components/RecentImports.vue'

defineOptions({ name: 'InaturalistImport' })

const summary = ref(null)

function onSubmitted(rows) {
  summary.value = rows
}
</script>
