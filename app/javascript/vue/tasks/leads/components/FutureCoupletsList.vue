<template>
  <div v-if="future.length">
    <div
      v-for="o in future.toReversed()"
      :key="o.cpl.id"
      :style="marginForDepth(o.depth)"
    >
      <CoupletChoiceLink
        :load-function="loadFunction"
        :route-name="routeName"
        :couplet-label="o.cplLabel"
        :lead="o.cpl"
        :otu-tag="o.otuLabel"
      />
    </div>
  </div>
  <div v-else>
    <i>No future couplets</i>
  </div>
</template>

<script setup>
import CoupletChoiceLink from './CoupletChoiceLink.vue'
import { marginForDepth } from '../helpers/formatters.js'

const props = defineProps({
  future: {
    type: Array,
    required: true
  },
  loadFunction: {
    type: Function,
    required: true
  },
  routeName: {
    type: String,
    required: true
  }
})
</script>
