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

import { onBeforeMount, ref } from 'vue'
import { getPastDateByDays } from 'helpers/dates.js'
import { CollectionObject } from 'routes/endpoints'
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

  params: {
    type: Object,
    default: () => ({})
  }
})

const emit = defineEmits(['onDate'])
const count = ref()

const handleClick = () => {
  emit('onDate', {
    user_date_start: getPastDateByDays(Number(props.days))
  })
}

onBeforeMount(async () => {
  count.value = (await CollectionObject.where(
    {
      ...props.params,
      user_date_end: getPastDateByDays(0),
      user_date_start: getPastDateByDays(Number(props.days))
    }
  )).headers['pagination-total']
})

</script>
