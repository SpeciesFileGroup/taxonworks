<template>
  <v-btn
    color="create"
    medium
    @click="generateDownload"
  >
    Download DwC
  </v-btn>
</template>
<script setup>
import VBtn from 'components/ui/VBtn/index.vue'
import { DwcOcurrence } from 'routes/endpoints'

const props = defineProps({
  params: {
    type: Object,
    required: true
  }
})

const generateDownload = () => {
  DwcOcurrence.generateDownload(props.params)
}
</script>
