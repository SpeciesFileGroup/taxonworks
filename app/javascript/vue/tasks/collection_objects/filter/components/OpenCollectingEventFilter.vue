<template>
  <v-btn
    color="primary"
    medium
    :disabled="!ids.length"
    @click="openTask"
  >
    Open in Filter Collecting Events
  </v-btn>
</template>

<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import { RouteNames } from 'routes/routes'

const props = defineProps({
  ids: {
    type: Object,
    default: () => ({})
  }
})

const openTask = () => {
  const ceIdParam = props.ids.map(id => `collection_object_id[]=${id}`).join('&')

  window.open(`${RouteNames.FilterCollectingEvents}?${ceIdParam}`, '_self')
}

</script>
