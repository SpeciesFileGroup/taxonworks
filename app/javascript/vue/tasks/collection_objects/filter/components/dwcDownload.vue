<template>
  <v-btn
    color="create"
    medium
    @click="download"
  >
    Download DwC
  </v-btn>
</template>
<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import { RouteNames } from 'routes/routes.js'
import { DwcOcurrence } from 'routes/endpoints'
import { transformObjectToParams } from 'helpers/setParam.js'

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

const getFilterParams = params => {
  const entries = Object.entries(params).filter(([key, value]) => !Array.isArray(value) || value.length)
  const data = Object.fromEntries(entries)

  data.per = props.total
  delete data.page

  return data
}

const download = () => {
  const downloadParams = getFilterParams(props.params)

  DwcOcurrence.generateDownload({ ...downloadParams }).then(_ => {
    window.open(`${RouteNames.DwcDashboard}?${transformObjectToParams(downloadParams)}`)
  })
}
</script>
