<template>
  <v-btn
    color="create"
    medium
    @click="handleClick">
    {{ label }}
  </v-btn>
</template>
<script setup>

import VBtn from 'components/ui/VBtn/index.vue'
import { getPastDateByDays } from 'helpers/dates.js'

const props = defineProps({
  label: {
    type: String,
    required: true
  },

  days: {
    type: [String, Number],
    required: true
  }
})

const emit = defineEmits(['onDate'])

const handleClick = () => {
  emit('onDate', {
    user_start_date: getPastDateByDays(Number(props.days))
  })
}

</script>
