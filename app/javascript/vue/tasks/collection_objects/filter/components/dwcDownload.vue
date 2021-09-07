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

const props = defineProps({
  params: {
    type: Object,
    required: true
  }
})

const clearParams = (params) => {
  const entries = Object.entries(params).filter(([key, value]) => !Array.isArray(value) || value.length)
  const data = Object.fromEntries(entries)

  delete data.per
  delete data.page

  return data
}

const download = () => {
  DwcOcurrence.generateDownload({ ...clearParams(props.params) }).then(_ => {
    window.open(RouteNames.DwcDashboard)
  })
}
</script>
