<template>
  <div v-if="past.length > 1">
    <template
      v-for="(o, i) in past"
      :key="o.id"
    >
      <div
        v-if="i > 0"
        :style="marginForDepth(i - 1)"
        class="new-lead-choice"
      >
        <OptionSetLink
          :load-function="loadFunction"
          :route-name="routeName"
          :option-set-label="past[i - 1].origin_label"
          :lead="o"
        />
      </div>
    </template>
  </div>
  <div v-else>
    {{ rootText }} <i>(At the start)</i>
  </div>
</template>

<script setup>
import OptionSetLink from './OptionSetLink.vue'
import { marginForDepth } from '../helpers/formatters.js'

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
</script>

<style lang="scss" scoped>
.new-lead-choice {
  margin-bottom: .2em;
}
</style>