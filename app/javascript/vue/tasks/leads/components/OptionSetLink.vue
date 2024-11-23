<template>
  <a
    :href="routeName + '?lead_id=' + lead.parent_id"
    @click.prevent="loadFunction(lead.parent_id)"
  >
    <template v-if="optionSetLabel">
      [{{ optionSetLabel }}]
    </template>

    <template v-if="lead.text">
      {{ leadText(lead) }}
    </template>
    <template v-else>
      <i>(No text)</i>
    </template>
  </a>
  <span
    v-if="otuTag"
    v-html="' ...' + otuTag"
  />
</template>

<script setup>
import { leadText } from '../helpers/formatters.js'

const props = defineProps({
  loadFunction: {
    type: Function,
    required: true
  },
  routeName: {
    type: String,
    required: true
  },
  optionSetLabel: {
    type: String,
    default: ''
  },
  lead: {
    type: Object,
    required: true
  },
  otuTag: {
    type: String,
    default: ''
  }
})
</script>
