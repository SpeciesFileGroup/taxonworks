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
          :validations="validations"
          :is="element"/>
      </template>
    </draggable>
  </div>
</template>

<script>

import Draggable from 'vuedraggable'
import sortComponent from '../../../shared/sortComponenets.vue'

import { SoftValidation } from 'routes/endpoints'
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
      return this.$store.getters[GetterNames.GetCollectionEvent]
    }
  },

  data () {
    return {
      keyStorage: 'tasks::digitize::mapOrder',
      componentsSection: 'ComponentMap',
      validations: {}
    }
  },

  watch: {
    lastSave: {
      handler (newVal) {
        if (newVal && this.collectingEvent.id) {
          SoftValidation.find(this.collectingEvent.global_id).then(response => {
            const validations = response.body
            this.validations = validations.soft_validations.lenght ? { collectingEvent: { list: validations, title: 'Collecting event' } } : {}
          })
        }
      },
      deep: true,
      immediate: true
    },

    collectingEvent (newVal, oldVal) {
      if (newVal.id && newVal.id != oldVal.id) {
        SoftValidation.find(this.collectingEvent.global_id).then(response => {
          const validations = response.body
          this.validations = validations.soft_validations.lenght ? { collectingEvent: { list: validations, title: 'Collecting event' } } : {}
        })
      } else if (!newVal.id) {
        this.validations = {}
      }
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
