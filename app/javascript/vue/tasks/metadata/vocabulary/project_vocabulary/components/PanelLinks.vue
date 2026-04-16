<template>
  <div
    v-if="QUERY_PARAM[model]"
    class="panel content"
  >
    <a
      :href="link"
      data-turbolink="false"
      >Open in field synchronize</a
    >
  </div>
</template>

<script setup>
import { RouteNames } from '@/routes/routes'
import { computed } from 'vue'
import { QUERY_PARAM } from '@/components/radials/filter/constants/queryParam'

const props = defineProps({
  model: {
    type: String,
    required: true
  },

  attribute: {
    type: String,
    required: true
  }
})

const link = computed(
  () =>
    `${RouteNames.FieldSynchronize}?model=${props.model}&attribute[]=${
      props.attribute
    }&${[QUERY_PARAM[props.model]]}[per]=50`
)
</script>
