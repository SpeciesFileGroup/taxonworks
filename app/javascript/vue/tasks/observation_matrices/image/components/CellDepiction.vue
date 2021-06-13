<template>
  <div>
    <div v-show="show">
      <draggable-component
        class="flex-wrap-row matrix-image-draggable"
        :group="{ name: 'cells', put: false }"
        :list="depictions"
        item-key="id"
        @choose="setObservationDragged"
        @remove="removeDepiction">
        <template #item="{ element }">
          <div class="drag-container">
            <image-viewer
              edit
              :depiction="element"
            >
              <template #thumbfooter>
                <div class="horizontal-left-content">
                  <radial-annotator
                    type="annotations"
                    :global-id="element.image.global_id"/>
                  <button-citation
                    :global-id="element.image.global_id"
                    :citations="element.image.citations"
                  />
                </div>
              </template>
            </image-viewer>
          </div>
        </template>
      </draggable-component>
    </div>
    <v-icon
      v-if="!show && depictions.length"
      name="image"/>
  </div>
</template>

<script>

import DraggableComponent from 'vuedraggable'
import VIcon from 'components/ui/VIcon/index.vue'
import ImageViewer from 'components/ui/ImageViewer/ImageViewer.vue'
import RadialAnnotator from 'components/radials/annotator/annotator.vue'
import ButtonCitation from './ButtonCitation.vue'
import { MutationNames } from '../store/mutations/mutations'

export default {
  components: {
    DraggableComponent,
    VIcon,
    ImageViewer,
    ButtonCitation,
    RadialAnnotator
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

  emits: ['removeDepiction'],

  methods: {
    setObservationDragged (event) {
      this.$store.commit(MutationNames.SetDepictionMoved, this.depictions[event.oldIndex])
    },

    removeDepiction ({ oldIndex }) {
      this.$emit('removeDepiction', oldIndex)
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
