<template>
  <div v-if="future.length">
    <div
      v-for="o in future.toReversed()"
      :key="o.cpl.id"
      :style="marginForDepth(o.depth)"
    >
      <a
        :href="routeName + '?lead_id=' + o.cpl.parent_id"
        @click.prevent="loadFunction(o.cpl.parent_id)"
        v-html="coupletText(o.cpl, o.cplLabel)"
      />
    </div>
  </div>
  <div
    v-else
    v-html="'<i>No future couplets</i>'"
  />
</template>

<script setup>
import { coupletText, marginForDepth } from '../helpers/formatters.js'

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
  },

})
</script>
