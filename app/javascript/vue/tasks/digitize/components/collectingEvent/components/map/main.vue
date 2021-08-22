<template>
  <div class="digitize-map-layout">
    <draggable
      v-model="componentsOrder"
      :disabled="!settings.sortable"
      :item-key="item => item"
      @end="updatePreferences">
      <template #item="{ element }">
        <component
          class="separate-bottom"
          :validations="softValidations"
          :is="element"/>
      </template>
    </draggable>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import sortComponent from '../../../shared/sortComponenets.vue'

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'
import {
  ComponentMap,
  VueComponents
} from '../../../../const/components'

const componentNames = Object.values(ComponentMap)
const MapComponents = Object.fromEntries(componentNames.map(componentName => [componentName, VueComponents[componentName]]))

export default {
  mixins: [sortComponent],

  components: {
    Draggable,
    ...MapComponents
  },

  computed: {
    settings: {
      get () {
        return this.$store.getters[GetterNames.GetSettings]
      },
      set (value) {
        this.$store.commit(MutationNames.SetSettings, value)
      }
    },

    lastSave () {
      return this.$store.getters[GetterNames.GetSettings].lastSave
    },

    collectingEvent () {
      return this.$store.getters[GetterNames.GetCollectingEvent]
    },

    softValidations () {
      return this.$store.getters[GetterNames.GetSoftValidations]
    }
  },

  data () {
    return {
      keyStorage: 'tasks::digitize::mapOrder',
      componentsSection: 'ComponentMap',
      validations: {}
    }
  }
}
</script>

<style lang="scss">
  .digitize-map-layout {
    max-width: 30%;
    label {
      display: block;
    }
  }
</style>
