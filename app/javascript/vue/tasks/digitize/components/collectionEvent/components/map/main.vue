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
          this.loadSoftValidation(this.collectingEvent.global_id)
        }
      },
      deep: true,
      immediate: true
    },

    collectingEvent (newVal, oldVal) {
      if (newVal.id && newVal.id !== oldVal.id) {
        this.loadSoftValidation(this.collectingEvent.global_id)
      } else if (!newVal.id) {
        this.validations = {}
      }
    }
  },

  methods: {
    loadSoftValidation (globalId) {
      SoftValidation.find(globalId).then(response => {
        const validations = response.body
        this.validations = { collectingEvent: { list: [validations], title: 'Collecting event' } }
      })
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
