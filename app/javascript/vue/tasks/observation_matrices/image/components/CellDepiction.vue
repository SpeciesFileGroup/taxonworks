<template>
  <div>
    <div v-show="show">
      <draggable-component
        class="flex-wrap-row matrix-image-draggable"
        :group="{ name: 'cells', put: false }"
        @choose="setObservationDragged"
        @remove="removedObservationFromList">
        <div
          v-for="depiction in depictions"
          :key="depiction.id"
          class="drag-container">
          <depiction-modal-viewer
            :depiction="depiction"
            is-original
          />
        </div>
      </draggable-component>
    </div>
    <v-icon
      v-if="!show && depictions.length"
      name="image"/>
  </div>
</template>

<script>

import DraggableComponent from 'vuedraggable'
import DepictionModalViewer from 'components/depictionModalViewer/depictionModalViewer.vue'
import VIcon from 'components/ui/VIcon/index.vue'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    DraggableComponent,
    DepictionModalViewer,
    VIcon
  },

  props: {
    show: {
      type: Boolean,
      default: true
    },

    depictions: {
      type: Array,
      default: () => ([])
    }
  },

  methods: {
    setObservationDragged (event) {
      this.$store.commit(MutationNames.SetDepictionMoved, this.depictions[event.oldIndex])
    },
    removedObservationFromList (event) {
      this.depictions.splice([event.oldIndex], 1)
    }
  }
}
</script>

<style scoped>
  .drag-container {
    padding-top: 0.5em;
  }

  .matrix-image-draggable {
    min-height: 100px;
    box-sizing: content-box;
  }
</style>
