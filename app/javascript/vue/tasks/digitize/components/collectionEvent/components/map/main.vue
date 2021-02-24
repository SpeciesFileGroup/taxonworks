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
        :is="component"/>
    </draggable>
  </div>
</template>

<script>

import LeafMap from './map.vue'
import PrintLabel from './printLabel'
import SoftValidation from './softValidation'
import DepictionComponent from './depictions'
import Draggable from 'vuedraggable'
import sortComponent from '../../../shared/sortComponenets.vue'

import { GetterNames } from '../../../../store/getters/getters'
import { MutationNames } from '../../../../store/mutations/mutations'

export default {
  mixins: [sortComponent],
  components: {
    LeafMap,
    DepictionComponent,
    PrintLabel,
    Draggable,
    SoftValidation
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
      componentsOrder: [
        'SoftValidation',
        'LeafMap',
        'PrintLabel',
        'DepictionComponent'
      ],
      keyStorage: 'tasks::digitize::mapOrder'
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
