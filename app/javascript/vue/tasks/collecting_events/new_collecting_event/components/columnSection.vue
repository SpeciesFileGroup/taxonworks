<template>
  <div class="panel content">
    <h2>{{ title }}</h2>
    <div class="horizontal-left-content align-start">
      <draggable
        class="full_width"
        v-for="(column, key) in componentsOrder"
        v-model="componentsOrder[key]"
        :key="key"
        :disabled="!sortable">
        <component
          class="separate-bottom"
          v-for="(componentName) in column"
          v-model="collectingEvent"
          :key="componentName"
          :is="componentName"/>
      </draggable>
    </div>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import { VueComponents } from '../const/components'
import extendCE from './mixins/extendCE'

export default {
  mixins: [extendCE],
  components: {
    Draggable,
    ...VueComponents
  },
  props: {
    componentNames: {
      type: Array,
      required: true
    },
    title: {
      type: String,
      default: ''
    }
  }
}
</script>