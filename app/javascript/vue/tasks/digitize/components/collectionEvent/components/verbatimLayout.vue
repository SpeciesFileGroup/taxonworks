<template>
  <div class="verbatim-layout">
    <h2>Verbatim</h2>
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
import {
  ComponentVerbatim,
  VueComponents
} from '../../../const/components'

import { GetterNames } from '../../../store/getters/getters'
import { MutationNames } from '../../../store/mutations/mutations'

const componentNames = Object.keys(ComponentVerbatim)
const VerbatimComponents = Object.fromEntries(componentNames.map(componentName => [componentName, VueComponents[componentName]]))

export default {
  mixins: [sortComponent],

  components: {
    Draggable,
    ...VerbatimComponents
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
      // componentsOrder: componentNames,
      keyStorage: 'tasks::digitize::verbatimOrder',
      componentsSection: 'ComponentVerbatim'
    }
  }
}
</script>

<style lang="scss">
  .verbatim-layout {
    label {
      display: block;
    }
    input[type="text"], textarea {
      width: 100%;
    }
  }
</style>