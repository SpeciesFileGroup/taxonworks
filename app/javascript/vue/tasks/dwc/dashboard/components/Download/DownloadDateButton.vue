<template>
  <v-btn
    color="create"
    medium
    :disabled="!count"
    @click="handleClick">
    {{ label }} ({{ count }})
  </v-btn>
</template>
<script setup>

import { getPastDateByDays } from 'helpers/dates.js'
import VBtn from 'components/ui/VBtn/index.vue'

const props = defineProps({
  label: {
    type: String,
    required: true
  },

  days: {
    type: [String, Number],
    required: true
  },

  count: {
    type: Number,
    required: true
  }
})

const emit = defineEmits(['onDate'])

const handleClick = () => {
  emit('onDate', {
    dwc_occurrence_end_date: getPastDateByDays(0),
    dwc_occurrence_start_date: getPastDateByDays(Number(props.days)),
    per: props.count
  })
}

</script>
