<template>
  <div v-if="future.length">
    <div
      v-for="o in future.toReversed()"
      :key="o.lead.id"
      :style="marginForDepth(o.depth)"
    >
      <OptionSetLink
        :load-function="loadFunction"
        :route-name="routeName"
        :option-set-label="o.leadLabel"
        :lead="o.lead"
        :otu-tag="o.otuLabel"
      />
    </div>
  </div>
  <div v-else>
    <i>No future option sets</i>
  </div>
</template>

<script setup>
import OptionSetLink from './OptionSetLink.vue'
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
