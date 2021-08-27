<template>
  <v-btn
    color="primary"
    medium
    @click="requestReindex">
    Re-index
  </v-btn>
</template>
<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import { DwcOcurrence } from 'routes/endpoints'

const props = defineProps({
  params: {
    type: Object,
    default: () => ({
      geographic_area_id: [49876546]
    })
  }
})

const requestReindex = () => {
  DwcOcurrence.createIndex({ ...props.params })
}

</script>
