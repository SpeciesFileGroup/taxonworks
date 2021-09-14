<template>
  <v-btn
    color="create"
    medium
    :disabled="isDisabled"
    @click="reindex"
  >
    Reindex DwC
  </v-btn>
</template>
<script setup>
import { computed } from 'vue'
import { RouteNames } from 'routes/routes.js'
import { DwcOcurrence } from 'routes/endpoints'
import { transformObjectToParams } from 'helpers/setParam.js'
import VBtn from 'components/ui/VBtn/index.vue'

const MIN_RECORDS = 5000
const props = defineProps({
  params: {
    type: Object,
    required: true
  },

  total: {
    type: Number,
    required: true
  }
})

const isDisabled = computed(() => props.total < MIN_RECORDS)

const clearParams = (params) => {
  const entries = Object.entries(params).filter(([key, value]) => !Array.isArray(value) || value.length)
  const data = Object.fromEntries(entries)

  delete data.per
  delete data.page

  return data
}

const reindex = () => {
  DwcOcurrence.createIndex({ ...clearParams(props.params) }).then(_ => {
    window.open(`${RouteNames.DwcDashboard}?${transformObjectToParams(clearParams(props.params))}`)
  })
}
</script>
