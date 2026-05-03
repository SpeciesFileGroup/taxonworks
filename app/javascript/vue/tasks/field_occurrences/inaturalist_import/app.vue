<template>
  <ImportForm
    @submitted="onSubmitted"
    class="margin-xlarge-bottom"
  />
  <SummaryTable
    v-if="summary"
    :rows="summary.rows"
    :find-mode="summary.findMode"
    @clear="summary = null"
  />
  <RecentImports
    class="margin-xlarge-top"
  />
</template>

<script setup>
import { ref } from 'vue'
import ImportForm from './components/ImportForm.vue'
import SummaryTable from './components/SummaryTable.vue'
import RecentImports from './components/RecentImports.vue'

defineOptions({ name: 'InaturalistImport' })

const summary = ref(null)

function onSubmitted(result) {
  summary.value = result
}
</script>
