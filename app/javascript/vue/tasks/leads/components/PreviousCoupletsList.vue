<template>
  <div v-if="past.length > 1">
    <template
      v-for="(o, i) in past"
      :key="o.id"
    >
      <div
        v-if="i > 0"
        :style="marginForDepth(i - 1)"
        class="new-lead-half-couplet"
      >
        <a
          :href="routeName + '?lead_id=' + (o.parent_id)"
          @click.prevent="loadFunction(o.parent_id)"
          v-html="textForParents(past, i)"
        />
      </div>
    </template>
  </div>
  <div v-else>
    {{ rootText }} <i>(At the start)</i>
  </div>
</template>

<script setup>
import { marginForDepth, coupletText } from '../helpers/formatters.js'

const props = defineProps({
  past: {
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
  rootText: {
    type: String,
    default: ''
  }
})

function textForParents(a, i) {
  return coupletText(a[i], a[i-1].origin_label)
}
</script>

<style lang="scss" scoped>
.new-lead-half-couplet {
  margin-bottom: .2em;
}
</style>