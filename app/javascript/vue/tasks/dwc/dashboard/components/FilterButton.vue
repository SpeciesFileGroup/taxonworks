<template>
  <v-btn
    medium
    color="primary">
    DwC Filter
  </v-btn>
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import { RouteNames } from 'routes/routes'

const props = defineProps({
  params: {
    type: Object,
    default: () => ({})
  }
})

const openFilter = () => {
  window.open(RouteNames.FilterCollectionObjects)
}

</script>
