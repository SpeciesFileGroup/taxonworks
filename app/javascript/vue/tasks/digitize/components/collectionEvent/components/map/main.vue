<template>
  <div class="digitize-map-layout">
    <draggable
      v-model="componentsOrder"
      @end="updatePreferences">
      <component
        v-for="component in componentsOrder"
        :key="component"
        :is="component"/>
    </draggable>
  </div>
</template>

<script>

import LeafMap from './map.vue'
import PrintLabel from './printLabel'
import DepictionComponent from './depictions'
import Draggable from 'vuedraggable'
import sortComponent from '../../../shared/sortComponenets.vue'

export default {
  mixins: [sortComponent],
  components: {
    LeafMap,
    DepictionComponent,
    PrintLabel,
    Draggable
  },
  data() {
    return {
      componentsOrder: [
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
    label {
      display: block;
    }
  }
</style>
