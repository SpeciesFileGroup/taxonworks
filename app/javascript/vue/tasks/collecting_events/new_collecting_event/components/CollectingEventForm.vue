<template>
  <div class="panel content">
    <div class="horizontal-left-content align-start">
      <div
        class="flex-wrap-column full_width margin-medium-right"
        v-for="(column, key) in componentsOrder">
        <h2 v-if="titleSection[key]">{{ titleSection[key] }}</h2>
        <draggable
          class="full_width"
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
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import { ComponentMap, ComponentParse, ComponentVerbatim, VueComponents } from '../const/components'

export default {
  components: {
    Draggable,
    ...VueComponents
  },
  props: {
    value: {
      type: Object,
      required: true
    },
    sortable: {
      type: Boolean,
      default: false
    }
  },
  computed: {
    collectingEvent: {
      get () {
        return this.value
      },
      set (value) {
        this.$emit('input', value)
      }
    },
    collectingEventId: {
      get () {
        return this.collectingEvent.id
      }
    }
  },
  watch: {
    componentsOrder: {
      handler (newVal) {
        console.log(newVal)
      },
      deep: true
    }
  },
  data () {
    return {
      componentsOrder: {
        componentVerbatim: Object.keys(ComponentVerbatim),
        componentParse: Object.keys(ComponentParse),
        componentMap: Object.keys(ComponentMap)
      },
      titleSection: {
        componentVerbatim: 'Verbatim',
        componentParse: 'Parse'
      }
    }
  }
}
</script>
