<template>
  <div>
    <div v-show="show">
      <draggable-component
        class="flex-wrap-row matrix-image-draggable"
        :group="{ name: 'cells', put: false }"
        :list="depictions"
        item-key="id"
        @choose="setObservationDragged"
      >
        <template #item="{ element }">
          <div class="drag-container">
            <image-viewer
              edit
              :depiction="element"
            >
              <template #thumbfooter>
                <div
                  class="horizontal-left-content padding-xsmall-bottom padding-xsmall-top gap-small"
                >
                  <radial-annotator
                    type="annotations"
                    :global-id="element.image.global_id"
                  />
                  <button-citation
                    :global-id="element.image.global_id"
                    :citations="element.image.citations"
                    @create="
                      (citation) =>
                        addToArray(depictions[index].image.citations, citation)
                    "
                    @delete="
                      (citation) =>
                        removeFromArray(
                          depictions[index].image.citations,
                          citation
                        )
                    "
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
      name="image"
    />
  </div>
</template>

<script setup>
import DraggableComponent from 'vuedraggable'
import VIcon from '@/components/ui/VIcon/index.vue'
import ImageViewer from '@/components/ui/ImageViewer/ImageViewer.vue'
import RadialAnnotator from '@/components/radials/annotator/annotator.vue'
import ButtonCitation from './ButtonCitation.vue'
import { addToArray, removeFromArray } from '@/helpers'
import { MutationNames } from '../store/mutations/mutations'
import { useStore } from 'vuex'

const store = useStore()

const props = defineProps({
  show: {
    type: Boolean,
    default: true
  },

  depictions: {
    type: Array,
    default: () => []
  }
})

function setObservationDragged(event) {
  store.commit(
    MutationNames.SetDepictionMoved,
    props.depictions[event.oldIndex]
  )
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
