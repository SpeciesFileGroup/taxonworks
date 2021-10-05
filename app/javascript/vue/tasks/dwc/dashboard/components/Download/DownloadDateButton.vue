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
    user_date_end: getPastDateByDays(0),
    user_date_start: getPastDateByDays(Number(props.days)),
    per: props.count
  })
}

</script>
