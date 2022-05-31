<template>
  <v-btn
    color="primary"
    medium
    :disabled="!urlParams"
    @click="openTask"
  >
    Send this filter to Match collection object
  </v-btn>
</template>
<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import { computed } from 'vue'
import { RouteNames } from 'routes/routes'

const props = defineProps({
  url: {
    type: String,
    required: true
  },

  ids: {
    type: Array,
    default: () => []
  }
})

const urlParams = computed(() =>
  props.ids.length
    ? props.ids.map(id => `collection_object_ids[]=${id}`).join('&')
    : props.url.split('?')[1]
)

const openTask = () => {
  window.open(RouteNames.MatchCollectionObject + '?' + urlParams.value)
}
</script>
