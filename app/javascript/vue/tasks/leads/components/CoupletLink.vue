<template>
  <a
    :href="routeName + '?lead_id=' + lead.parent_id"
    @click.prevent="loadFunction(lead.parent_id)"
  >
    <template v-if="coupletLabel">
      [{{ coupletLabel }}]
    </template>

    <template v-if="lead.text">
      {{ leadText(lead) }}
    </template>
    <template v-else>
      <i>(No text)</i>
    </template>

    <template v-if="!!leadItemsCount">
      <span v-if="leadItemsCount == 1"> (&#10003;)</span>
      <span v-else> ({{ leadItemsCount }} otus left)</span>
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
  coupletLabel: {
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
  },
  // Only ever actually used with the New/Edit task, not Show.
  leadItemsCount: {
    type: Number,
    default: 0
  }
})

</script>
