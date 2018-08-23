<template>
  <div class="digitize-map-layout">
    <draggable v-model="componentsOrder">
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

export default {
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
      ]
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
