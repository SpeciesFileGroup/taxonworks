<template>
  <div class="geography-layout">
    <h2>Parsed</h2>
    <draggable
      v-model="componentsOrder"
      :disabled="!settings.sortable"
      :item-key="item => item"
      @end="updatePreferences">
      <template #item="{ element }">
        <component
          class="separate-bottom"
          :is="element"/>
      </template>
    </draggable>
  </div>
</template>
<script>

import Draggable from 'vuedraggable'
import sortComponent from '../../shared/sortComponenets.vue'

import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'
import {
  ComponentParse,
  VueComponents
} from '../../../const/components'

const componentNames = Object.keys(ComponentParse)
const ParseComponents = Object.fromEntries(componentNames.map(componentName => [componentName, VueComponents[componentName]]))

export default {
  mixins: [sortComponent],
  components: {
    Draggable,
    ...ParseComponents
  },
  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    }
  },
  data () {
    return {
      componentsOrder: componentNames,
      keyStorage: 'tasks::digitize::GeographyOrder',
      componentsSection: 'ComponentParse'
    }
  }
}
</script>

<style lang="scss">
  .geography-layout {
    label {
      display: block;
    }
    li label {
      display: inline;
    }
  }
</style>
