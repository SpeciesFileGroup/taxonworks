<template>
  <div class="panel content">
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
import { ComponentMap, ComponentParse, ComponentVerbatim, VueComponents } from '../const/components'
import { GetterNames } from '../store/getters/getters'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    Draggable,
    ...VueComponents
  },
  computed: {
    collectingEvent: {
      get () {
        return this.$store.getters[GetterNames.GetCollectingEvent]
      },
      set (value) {
        this.$store.commit(MutationNames.SetCollectingEvent)
      }
    }
  },
  data () {
    return {
      componentsOrder: {
        componentVerbatim: Object.keys(ComponentVerbatim),
        componentParse: Object.keys(ComponentParse),
        componentMap: Object.keys(ComponentMap)
      },
      sortable: true
    }
  }
}
</script>
