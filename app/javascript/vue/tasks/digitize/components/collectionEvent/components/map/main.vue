<template>
  <div class="digitize-map-layout">
    <draggable
      v-model="componentsOrder"
      :disabled="!settings.sortable"
      @end="updatePreferences">
      <component
        class="separate-bottom"
        v-for="component in componentsOrder"
        :key="component"
        :validations="validations"
        :is="component"/>
    </draggable>
  </div>
</template>

<script>

import LeafMap from './map.vue'
import PrintLabel from './printLabel'
import SoftValidationComponent from 'components/soft_validations/panel'
import DepictionComponent from './depictions'
import Draggable from 'vuedraggable'
import sortComponent from '../../../shared/sortComponenets.vue'

import { SoftValidation } from 'routes/endpoints'
import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  mixins: [sortComponent],
  components: {
    LeafMap,
    DepictionComponent,
    PrintLabel,
    Draggable,
    SoftValidationComponent
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
      componentsOrder: [
        'SoftValidationComponent',
        'LeafMap',
        'PrintLabel',
        'DepictionComponent'
      ],
      keyStorage: 'tasks::digitize::mapOrder',
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
